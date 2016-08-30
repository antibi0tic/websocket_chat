var socket;
var username;

function start_chat()
{
    socket = new WebSocket("ws://localhost:8088/websocket");
    username = "";

    socket.onopen = function() {
      alert("Connection opened.");
    };

    socket.onclose = function(event) {
      logout();
      if (event.wasClean) {
        alert('Connection closed. Refresh page to chat again.');
      } else {
        alert('Connection lost. Refresh page to chat again.');
      }
    };

    socket.onerror = function(error) {
      alert("Error: " + error.message);
    };

    document.forms.login_form.onsubmit = function() {
      username = this.username.value.trim();
      if (!username) {
        alert("Enter username");
      } else {
        var outgoingMessage = {
                room: "main",
                req: "login",
                data: username
              };

        socket.send(outgoingMessage);
      }
      return false;
    };

    document.forms.send_message_form.onsubmit = function() {
          if (!username) {
            alert("Enter username");
          } else {
            var outgoingMessage = {
                    room: "main",
                    req: "send_message",
                    data: this.message.value.trim()
                  };

            socket.send(outgoingMessage);
          }
          return false;
        };

    socket.onmessage = function(event) {
      var incomingMessage = event.data;
      if (incomingMessage === "welcome") {
        login_success();
      } else {
        showMessage(incomingMessage);
      }
    };
}

function showMessage(message) {
  var messageElem = document.createElement('div');
  messageElem.appendChild(document.createTextNode(message));
  document.getElementById('messages_list').appendChild(messageElem);
}

function login_success() {
    document.getElementById('login_div').style.display = "none";
    document.getElementById('room_div').style.display = "block";
}

function logout() {
    username = "";
    document.getElementById('login_div').style.display = "block";
    document.getElementById('room_div').style.display = "none";
}