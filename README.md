# WebSocket chat

Simple web-chat written on Cowboy, Erlang and based on WebSockets as transport layer.

## Requirements

[Rebar3](https://github.com/erlang/rebar3) tool is used for project lifecycle

```bash
wget https://s3.amazonaws.com/rebar3/rebar3 && chmod +x rebar
```

## Build

```bash
$ make compile
===> Verifying dependencies...
===> Compiling cowlib
===> Compiling ranch
===> Compiling jsx
===> Compiling cowboy
===> Compiling websocket_chat
```

## Run

```bash
make start
```

## TODO

- Extra goal do it without cowboy. :)