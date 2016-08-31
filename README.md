WebSocket chat
=====
Simple web-chat written on Erlang
and based on WebSockets as transport layer.

Extra goal (not done): do it without cowboy. :)


Build
-----

    $ rebar3 compile

Run
---

    erl -pa _build/default/lib/cowboy/ebin/ -pa _build/default/lib/cowlib/ebin/ -pa _build/default/lib/ranch/ebin/ -pa _
    build/default/lib/websocket_chat/ebin/ -pa _build/default/lib/jsx/ebin/ -s websocket_chat_app fast_start