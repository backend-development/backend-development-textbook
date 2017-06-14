Websockets with Node
=========================

While HTTP only allows requests from the client sent to the server,
websockets offer a permanent connection between client and server.
With socket.io you can use websockets in node.

By referring to this guide, you will be able to:

* Build a chat app in node
* Incorporate "server push" functionality in your app


-------------------------------------------------------------

Websockets
-------

Websockets are built on top of HTTP and HTTPS:

* they reuse the default ports 80 and 445
* they start out as a normal HTTP request
* they reuse cookies

but after the initial request, a websocket turns into
a permanent connection between the server and the client.


```
GET /chat HTTP/1.1
Host: server.example.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Origin: http://example.com
Sec-WebSocket-Protocol: chat, superchat
Sec-WebSocket-Version: 13

HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
Sec-WebSocket-Protocol: chat 
```

Both the client and the server can send messages across
the websocket at any time.  Both the client and the
server should be able to handle incoming messages at any time.

Warning: Leaving the restful area
--------

Up to now we have been building RESTful APIs and classical
web applications that try to be as RESTful as possible.
Using websockets you are building a completely different
type of distributed system.

See [jfriend00(2015) answer on stackoverflow](https://stackoverflow.com/questions/29925955/what-are-the-pitfalls-of-using-websockets-in-place-of-restful-http#answer-29933428) for an in depth comparison.


Socket.io
----

socket.io
Library for both server and client side JS code
Needs express as a basis

WARNING: 
socket.io will automatically host some files needed on the client side under the URL /socket.io/  Do not attempt to change this!


Load in client:

```
<script src="socket.io/socket.io.js"></script>
```


## Overview


```
const app = require('express')();
const http = require('http').Server(app);
const io = require('socket.io')(http);
const port = process.env.PORT || 5000;

app.use(express.static('public'));

http.listen(port, function(){
  console.log("webserver started");
});

io.on(…)

// export app so we can test it
exports = module.exports = app;

```

## Client

```
<ul id="messages"></ul>
<form action="">
  <input id="m" autocomplete="off" /><button>Send</button>
</form>
<script src="https://code.jquery.com/jquery-2.2.3.min.js"></script>
<script src="socket.io/socket.io.js"></script>
```

Sending messages to the server:

```
<script>
  var socket = io();
  $('form').submit(function(){
    socket.emit('chat message', $('#m').val());
    $('#m').val('');
    return false;
  });
</script>
```

Recieving messages from the server:

```
  socket.on('chat message', function(msg){
    $('#messages').append($('<li>').text(msg));
  });
```





## Server

```
io.on('connection', function(socket){
  console.log('a user connected');

  socket.on('chat message', function(msg){
    console.log(`got message '${msg}', broadcasting to all`);
    io.emit('chat message', msg);
  });

  socket.on('disconnect', function(){
    console.log('user disconnected');
  });
});
```

## Testing the Server

```
describe("Auction Server",function(){
  it('Should echo chat massages back to user', function(done){
    var client1 = io.connect(socketURL, options);

    client1.on('connect', function(data){
      client1.emit('chat message', 'hello world');
      client1.on('chat message', function(data){
        console.log('got back ' + data);
        data.should.equal('hello world');
        client1.disconnect();
        done();
      });
    });
  });
});

```






See Also
-----

* [RFC 6455](https://tools.ietf.org/html/rfc6455)