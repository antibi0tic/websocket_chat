%%%-------------------------------------------------------------------
%% @doc websocket_chat top level supervisor.
%% @end
%%%-------------------------------------------------------------------
-module(handler_websocket).

%% API
-export([response_login/2, response_logout/2, response_new_message/3]).

%% Callbacks
-export([init/2, websocket_handle/2, websocket_info/2, websocket_terminate/2]).

%%%===================================================================
%%% API
%%%===================================================================

response_login(Pid, Room) ->
	response(Pid, Room, <<"login">>, <<"success">>).

response_logout(Pid, Room) ->
	response(Pid, Room, <<"logout">>, <<"">>).

response_new_message(Pid, Room, Msg) ->
	response(Pid, Room, <<"new_message">>, Msg).

%%%===================================================================
%%% Callbacks
%%%===================================================================

init(Req, State) ->
	{cowboy_websocket, Req, State}.

websocket_handle({text, Msg}, State) ->
	MsgMap = jsx:decode(Msg, [return_maps]),
	#{
		<<"room">> := Room,
		<<"req">> := Req,
		<<"data">> := Data
	} =  MsgMap,
	case Req of
		<<"login">> -> chat_room:login(Room, Data);
		<<"send_message">> -> chat_room:send_message(Room, Data);
		<<"logout">> -> chat_room:logout(Room)
	end,
	{ok, State};
websocket_handle(_Data, State) ->
	{ok, State}.

websocket_info(Info, State) ->
	Msg = jsx:encode(Info),
	{reply, {text, Msg}, State}.

websocket_terminate(_Reason, _State) ->
	ok.

%% Internal functions
response(Pid, Room, Type, Data) ->
	Resp = #{
		<<"room">> => Room,
		<<"resp">> => Type,
		<<"data">> => Data
	},
	Pid ! Resp.