%%%-------------------------------------------------------------------
%% @doc websocket_chat top level supervisor.
%% @end
%%%-------------------------------------------------------------------
-module(handler_websocket).

%% API
-export([response_logout/2, response_new_message/3]).

%% Callbacks
-export([init/2, websocket_init/1, websocket_handle/2, websocket_info/3, websocket_terminate/3]).

%%%===================================================================
%%% API
%%%===================================================================

response_login(Pid, Room) ->
	response(Pid, Room, <<"login">>, <<"200">>).

response_logout(Pid, Room) ->
	response(Pid, Room, <<"logout">>, <<"">>).

response_new_message(Pid, Room, Msg) ->
	response(Pid, Room, <<"new_message">>, Msg).

%%%===================================================================
%%% Callbacks
%%%===================================================================

init(Req, Opts) ->
	{cowboy_websocket, Req, Opts}.

websocket_init(State) ->
	{ok, State}.

websocket_handle({text, Msg}, State) ->
	#{
		<<"room">> := Room,
		<<"req">> := Req,
		<<"data">> := Data
	} =  jsx:decode(Msg, [return_maps]),
	case Req of
		<<"login">> -> websocket_chat_room:login(Room, Data);
		<<"send_message">> -> websocket_chat_room:send_message(Room, Data);
		<<"logout">> -> websocket_chat_room:logout(Room)
	end,
	{ok, State};
websocket_handle(_Data, State) ->
	{ok, State}.

websocket_info(Info, Req, State) ->
	Msg = jsx:encode(Info),
	{reply, {text, Msg}, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.

%% Internal functions
response(Pid, Room, Type, Data) ->
	Resp = #{
		<<"room">> => Room,
		<<"resp">> => Type,
		<<"data">> => Data
	},
	Pid ! Resp.