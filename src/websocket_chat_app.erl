%%%-------------------------------------------------------------------
%% @doc websocket_chat public API
%% @end
%%%-------------------------------------------------------------------

-module(websocket_chat_app).

-include("websocket_chat.hrl").

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
%% Debug starting callbacks
-export([fast_start/0, fast_stop/0]).

-define(DEFAULT_PORT, 8088).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, websocket_chat, "www/index.html"}},
			{"/websocket", handler_websocket, []},
			{"/[...]", cowboy_static, {priv_dir, websocket_chat, "www"}}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, 100, [{port, ?DEFAULT_PORT}], #{env => #{dispatch => Dispatch}}),
	ets:new(?ROOMS_TABLE, [public, named_table]),
	websocket_chat_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%--------------------------------------------------------------------
fast_start() ->
	application:start(ranch),
	application:start(crypto),
	application:start(cowlib),
	application:start(cowboy),
	application:start(jsx),
	application:start(websocket_chat).

%%--------------------------------------------------------------------
fast_stop() ->
	application:stop(websocket_chat),
	application:stop(jsx),
	application:stop(cowboy),
	application:stop(cowlib),
	application:stop(crypto),
	application:stop(ranch).

%%====================================================================
%% Internal functions
%%====================================================================
