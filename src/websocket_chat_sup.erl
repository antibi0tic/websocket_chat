%%%-------------------------------------------------------------------
%% @doc websocket_chat top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(websocket_chat_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_room/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_room(Name) ->
	supervisor:start_child(?SERVER, [Name]).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
	Room = {room,
		{websocket_chat_room, start_link, []},
		permanent, 3000, worker, [websocket_chat_room]
		},
	{ok, { {simple_one_for_one, 1, 30}, [Room]} }.

%%====================================================================
%% Internal functions
%%====================================================================
