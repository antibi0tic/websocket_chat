FROM erlang:latest
WORKDIR /opt/websocket
COPY . ./
ENV TERM=xterm \
    MIX_ENV=prod \
    REPLACE_OS_VARS=true \
    APP_NAME=renew_sample \
    APP_VERSION=0.1.0

RUN apt-get install make && \
    apt-get install ca-certificates && \
    make compile

WORKDIR  _build/default/lib/websocket_chat/ebin
ENTRYPOINT erl -pa /opt/websocket/_build/default/lib/cowboy/ebin/ -pa /opt/websocket/_build/deflt/lib/cowlib/ebin/ -pa /opt/websocket/_build/default/lib/ranch/ebin/ -pa /opt/websocket/_build/default/lib/websocket_chat/ebin/ -pa /opt/websocket/_build/default/lib/jsx/ebin/ -s websocket_chat_app fast_start -noshell