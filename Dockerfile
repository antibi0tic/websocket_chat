FROM erlang:20.0.1-slim
RUN apt-get update && apt-get install git-core -y && apt-get autoremove && apt-get clean
ADD https://s3.amazonaws.com/rebar3/rebar3 /bin/
RUN chmod +x /bin/rebar3
COPY websocket_chat /tmp/websocket_chat

WORKDIR /tmp/websocket_chat
RUN rebar3 as prod release -o /svcs

WORKDIR /svcs/websocket_chat/bin

EXPOSE 8080

ENTRYPOINT ["./websocket_chat",  "foreground"]