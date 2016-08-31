%%%-------------------------------------------------------------------
%% @doc websocket_chat top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(websocket_chat_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
	RoomSup = {chat_room_sup,
		{chat_room_sup, start_link, []},
		permanent, 5000, supervisor, [chat_room_sup]
		},
	BotSup = {bot_sup,
		{bot_sup, start_link, []},
		permanent, 5000, supervisor, [bot_sup]
	},
	{ok, { {one_for_one, 1, 30}, [RoomSup, BotSup]} }.

%%====================================================================
%% Internal functions
%%====================================================================
