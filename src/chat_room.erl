%%%-------------------------------------------------------------------
%%% @doc
%%% @end
%%%-------------------------------------------------------------------
-module(chat_room).

-include("websocket_chat.hrl").

-behaviour(gen_server).

%% API
-export([start_link/0, start_link/1]).
-export([login/2,
	logout/1,
	send_message/2,
	get_messages/1,
	get_users/1]).

%% gen_server callbacks
-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-define(MAX_MESSAGES_LENGTH, 500).
-record(state, {name, messages = [], users = []}).
-record(user, {pid, name}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
	start_link(<<"main">>).
start_link(Name) ->
	gen_server:start_link(?MODULE, [Name], []).

login(Room, Username) ->
	case ets:lookup(?ROOMS_TABLE, Room) of
		[{Room, Pid}] -> gen_server:cast(Pid, {login, {Username, self()}});
		[] -> error(room_not_found)
	end.

logout(Room) ->
	case ets:lookup(?ROOMS_TABLE, Room) of
		[{Room, Pid}] -> gen_server:cast(Pid, {logout, self()});
		[] -> error(room_not_found)
	end.

send_message(Room, Msg) ->
	case ets:lookup(?ROOMS_TABLE, Room) of
		[{Room, Pid}] -> gen_server:cast(Pid, {send_message, {self(), Msg}});
		[] -> error(room_not_found)
	end.

get_messages(Room) ->
	case ets:lookup(?ROOMS_TABLE, Room) of
		[{Room, Pid}] -> gen_server:cast(Pid, {get_messages, self()});
		[] -> error(room_not_found)
	end.

get_users(Room) ->
	case ets:lookup(?ROOMS_TABLE, Room) of
		[{Room, Pid}] -> gen_server:cast(Pid, {get_users, self()});
		[] -> error(room_not_found)
	end.

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([Name]) ->
	ets:insert(?ROOMS_TABLE, {Name, self()}),
	{ok, #state{name = Name}}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast({login, {Username, Pid}}, #state{users = OldUsers} = State) ->
	User = #user{name = Username, pid = Pid},
	%% TODO: check if user already in room
	handler_websocket:response_login(Pid, State#state.name),
	{noreply, State#state{users = [User | OldUsers]}};

handle_cast({logout, Pid}, #state{users = OldUsers} = State) ->
	NewUsers = lists:keydelete(Pid, #user.pid, OldUsers),
	%% TODO: inform others about logout
	{noreply, State#state{users = NewUsers}};

handle_cast({send_message, {Pid, Msg}}, #state{users = Users, messages = Messages, name = Room} = State) ->
	case lists:keyfind(Pid, #user.pid, Users) of
		false -> {noreply, State}; %% TODO: need to do something with it
		#user{pid = Pid, name = Username} ->
			FmtMsg = format_message(Username, Msg),
			NewMessages = if
											erlang:length(Messages) < ?MAX_MESSAGES_LENGTH -> [FmtMsg | Messages];
											true -> [FmtMsg | lists:droplast(Messages)]
										end,
			lists:foreach(
				fun(#user{pid = UserPid}) ->
					handler_websocket:response_new_message(UserPid, Room, FmtMsg)
				end,
				Users),
			{noreply, State#state{messages = NewMessages}}
	end;

handle_cast({get_messages, Pid}, #state{messages = Messages, name = Room} = State) ->
	handler_websocket:response_message_history(Pid, Room, Messages),
	{noreply, State};

handle_cast({get_users, Pid}, #state{users = Users, name = Room} = State) ->
	UserNames = [Name || #user{name = Name} <- Users],
	handler_websocket:response_users(Pid, Room, UserNames),
	{noreply, State};

handle_cast(_Request, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, State) ->
	ets:delete(?ROOMS_TABLE, State#state.name),
	%% TODO: inform users about termination
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
format_message(Username, MsgText) ->
	{{Y, M, D},{HH, MI, SS}} = calendar:universal_time(),
	Timestamp = unicode:characters_to_binary(io_lib:format("~p.~p.~p ~p:~p:~p ", [Y, M, D, HH, MI, SS])),
	<<Timestamp/bitstring, "@"/utf8, Username/bitstring, ": "/utf8, MsgText/bitstring>>.