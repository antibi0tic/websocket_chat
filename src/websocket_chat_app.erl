%%%-------------------------------------------------------------------
%% @doc websocket_chat public API
%% @end
%%%-------------------------------------------------------------------

-module(websocket_chat_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

-define(DEFAULT_PORT, 8088).

%% Debug starting callbacks
-export([fast_start/0, fast_stop/0]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, websocket_chat_app, "www/index.html"}},
			{"/websocket", handler_websocket, []},
			{"/[...]", cowboy_static, {priv_dir, websocket_chat_app, "www"}}
		]}
	]),
	{ok, _} = cowboy:start_clear(http, 100, [{port, ?DEFAULT_PORT}], #{env => #{dispatch => Dispatch}}),
	websocket_chat_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%--------------------------------------------------------------------
fast_start() ->
	application:start(cowboy),
	application:start(websocket_chat).

%%--------------------------------------------------------------------
fast_stop() ->
	application:stop(websocket_chat),
	application:stop(cowboy).

%%====================================================================
%% Internal functions
%%====================================================================
