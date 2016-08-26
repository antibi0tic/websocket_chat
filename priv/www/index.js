var socket = new WebSocket("ws://localhost:8089");

socket.onopen = function() {
  alert("Connection opened.");
};

socket.onclose = function(event) {
  if (event.wasClean) {
    alert('Connection closed. Refresh page to chat again.');
  } else {
    alert('Connection lost. Refresh page to chat again.');
  }
};

socket.onmessage = function(event) {
  alert("Recieved: " + event.data);
};

socket.onerror = function(error) {
  alert("Error: " + error.message);
};

document.forms.login_form.onsubmit = function() {
  var outgoingMessage = {
    room: "main",
    req: "login",
    data: this.username.value
  };

  socket.send(outgoingMessage);
  return false;
};

socket.onmessage = function(event) {
  var incomingMessage = event.data;
  showMessage(incomingMessage);
};

function showMessage(message) {
  var messageElem = document.createElement('div');
  messageElem.appendChild(document.createTextNode(message));
  document.getElementById('messages_list').appendChild(messageElem);
}

function login_success(username) {
    document.getElementById('login_div').style.display = "none";
    document.getElementById('room_div').style.display = "block";
}