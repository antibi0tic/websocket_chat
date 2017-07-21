%%%-------------------------------------------------------------------
%%% @doc Bot example
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(bot_example).

-behaviour(gen_server).

%% API
-export([start_link/0, start_link/1]).

%% gen_server callbacks
-export([init/1,
	handle_call/3,
	handle_cast/2,
	handle_info/2,
	terminate/2,
	code_change/3]).

-define(SERVER, ?MODULE).
-define(SPAM_TIMEOUT_MILISEC, 30000). %% 30 seconds

-record(state, {room, timer}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
	start_link(<<"main">>).

start_link(Room) ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, [Room], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([Room]) ->
	chat_room:login(Room, <<"BotExample">>),
	Timer = erlang:send_after(?SPAM_TIMEOUT_MILISEC, self(), spam),
	{ok, #state{room = Room, timer = Timer}}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Request, State) ->
	{noreply, State}.

handle_info(spam, #state{room = Room, timer = OldTimer} = State) ->
	erlang:cancel_timer(OldTimer),
	chat_room:send_message(Room, <<"Cute androids! Free, without sms!">>),
	NewTimer = erlang:send_after(?SPAM_TIMEOUT_MILISEC, self(), spam),
	{noreply, State#state{timer = NewTimer}};

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
