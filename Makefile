
.PHONY: all clean compile start

all: clean compile start

compile:
	rebar3 compile

clean:
	rebar3 clean

start: compile
	erl -pa _build/default/lib/cowboy/ebin/ -pa _build/default/lib/cowlib/ebin/ -pa _build/default/lib/ranch/ebin/ -pa _build/default/lib/websocket_chat/ebin/ -pa _build/default/lib/jsx/ebin/ -s websocket_chat_app fast_start