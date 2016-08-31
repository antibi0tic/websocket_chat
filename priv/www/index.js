var socket;
var username;
var users_list;

function start_chat()
{
    socket = new WebSocket("ws://localhost:8088/websocket");
    username = "";

    socket.onopen = function() {
      console.log("Connection opened.");
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
        request("login", username);
      }
      return false;
    };

    document.forms.send_message_form.onsubmit = function() {
          if (!username) {
            alert("Enter username");
          } else {
            request("send_message", this.message.value.trim());
          }
          return false;
        };

    socket.onmessage = function(event) {
      var incomingMessage = JSON.parse(event.data);
      if (incomingMessage.resp === "login" && incomingMessage.data === "success") {
        login_success();
        request("message_history");
        request("users");
      } else if (incomingMessage.resp === "new_message") {
        showMessage(incomingMessage.data);
      } else {
        console.log("Strange incoming message: " + event.data);
      }
    };
}

function request(req_type, req_data = "") {
    var outgoingMessage = {
                        room: "main",
                        req: req_type,
                        data: req_data
                      };
    socket.send(JSON.stringify(outgoingMessage));
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