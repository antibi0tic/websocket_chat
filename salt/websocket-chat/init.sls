websocket_chat:
  docker_container.running:
    - image: "allexx/websocket_chat:travis-17"
    - port_bindings:
      - 8080:80