Rails Websockets
=======================

While HTTP only allows requests from the client sent to the server,
websockets offer a permanent connection between client and server.
With Actioncable you can use websockets for publish-subscribe communication.

By referring to this guide, you will be able to:

* Incorporate "Server Push" funktionality in your app
* Build a chat app in your webapp

REPO: You can study the [code](https://github.com/backend-development/rails-websockets) and try out [the demos](https://stepstones.herokuapp.com/) for the example app described here.

---------------------------------------------------------------------------

TBD

Websockets
-------

Websockets are built on top of HTTP and HTTPS:

* they reuse the default ports 80 and 445
* they start out as a normal HTTP request
* they reuse cookies

but after the initial request, a websocket turns into
a permanent connection between the server and the client.

Both the client and the server can send messages across
the websocket at any time.  Both the client and the
server should be able to handle incoming messages at any time.


Publish-Subscribe
-------



In Rails we have to distinguish two concepts:

* The websocket **connection** deals with authenticating a user - see `app/channels/application_cable/connection.rb`
* A **channel** 
* A **stream** inside a channel


Example App
-------

In our example app several users are working on "adventures" which
consist of several "steps".  All the users should be able to chat
with teach other in one big chatroom.
All the users *in one adventure* should see each other progress through the steps.


We will build the app starting from the client side:

### Client connects and subscribes

The javascript concerning websockets is stored in the
file `app/assets/javascripts/cabel.js` which was created
by rails. It should look like this:

```javascript
//= require action_cable
//= require_self
//= require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();
}).call(this);
```

and which in turn includes the folder `app/assets/javascripts/channels`
where we will store our own javascript.  


To connect each user to the chat channel, we add a new file
`app/assets/javascripts/channels/chat.js`:

```javascript
App.chatChannel = App.cable.subscriptions.create({
  channel: 'ChatChannel',
  room: 'main'
}
```

This tries to subscribe to a channel on the server via websocket
If you open your app in the browser now, you should
see an error in the developer tools console:

```
WebSocket connection to 'ws://localhost:3000/cable' failed: Error during WebSocket handshake: Unexpected response code: 500
```

So the client is trying to connect, but it does not work yet.



### Server accepts

The server side code is stored in the folder `app/channels`. We first
take a look at `app/channels/application_cable/connection.rb`, which was
created by rails:

```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base
  end
end
```

Remember that the server side code concerning websocket is not
called by a controller.  So even if we already built authentication
into our app, and added code for `current_user` to `application_controller.rb`,
the `current_user` will not be available here in the ApplicationCable.

But we do have access to cookies in Actioncable:

```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user    # creates a instance variable

    def connect
      Rails.logger.warn("this is the info I read from the cookie:")
      Rails.logger.warn(cookies.encrypted[Rails.application.config.session_options[:key]])
      self.current_user = User.find(3)
    end

    def disconnect
      # Any cleanup work needed when the cable connection is cut.
    end    
  end
end
```

After adding this code the browser should be able to connect to
the websocket.  In Firefox with the extension **Websocket Monitor** you
can see the messages sent across the websocket in a separate tab:

![Websocket in Firefox with Extension Websocket Monitor](images/ws_firefox.png)

You can see that there is more going on than just the subscription
that we initiated from the client side.


On the server side you will see the connection in the log file:

```
Started GET "/cable" for ::1 at 2017-01-25 17:45:09 +0100
Started GET "/cable/" [WebSocket] for ::1 at 2017-01-25 17:45:09 +0100
Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: keep-alive, Upgrade, HTTP_UPGRADE: websocket)
this is the info I read from the cookie:
{"session_id"=>"b8ee74d5afe32d5", "_csrf_token"=>"9mBRsEoGnRnkkW6", "user_id"=>"3"}
```

We successfully decoded the session data from the encrypted cookie, you can see 
that the `user_id` is 3 in this case. We can use this to set the `current_user` correctly:

```ruby
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user    # creates a instance variable

    def connect
      session_from_cookie = cookies.encrypted[Rails.application.config.session_options[:key]]
      user_id = session_from_cookie['user_id']
      reject_unauthorized_connection if user_id.nil?
      self.current_user = User.find(user_id)
      Rails.logger.warn("connection for user #{current_user}")
      reject_unauthorized_connection if current_user.nil?
    end

    def disconnect
      # Any cleanup work needed when the cable connection is cut.
    end    
  end
end
```

After this a user that has logged in to the rails app is
automatically also logged in to the websocket, as you
can see in the log file:


```
Started GET "/cable" for ::1 at 2017-01-25 17:54:51 +0100
Started GET "/cable/" [WebSocket] for ::1 at 2017-01-25 17:54:51 +0100
Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: keep-alive, Upgrade, HTTP_UPGRADE: websocket)
  User Load (0.3ms)  SELECT  "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 3], ["LIMIT", 1]]
connection for user Brigitte Jellinek
Registered connection (Z2lkOi8vc3RlcHN0b25lcy9Vc2VyLzM)
ChatChannel is transmitting the subscription confirmation
ChatChannel is streaming from chat_main
```


### Client sends data

To implement the chat we can use the already existing HTML in application.html.erb:

```
<section id="chat" class="holder">
  <div id="output">
    <p>Chat...</p>
  </div>
  <div id="input">
    <span><%= current_user %>: </span>
    <input name="chat" type="text">
    <input type="button" value="send">
  </div>
</section>
```

If a user types something into the chat-input field and
presses enter or the send button, we want the text to
be sent across the websocket:

```Javascript
$(function() {
  function send_chat() {
    var text = $('#input input[name=chat]').val();
    $('#input input[name=chat]').val('');
    App.chatChannel.send({ body: text });
  }

  $('#input input[name=chat]').on('keypress',function (e) {
    if (e.which == 13 || e.keyCode == 13) {
      send_chat();  
    }
  });

  $('#input input[type=button]').on('click', send_chat);
});
```

If you type in 'Hello' and send it, you can see the message
being sent in the websocket tab of firefox developer tools:

![chat message being sent to the server](images/ws_firefox_send.png)

### Server recives data

Right now the server does not know how to handle the incoming data,
in the log file you will read:

```
Unable to process ChatChannel#receive({"body"=>"hello"})
```

We implement `receive` in `app/channels/chat_channel.rb`:

```
class ChatChannel < ApplicationCable::Channel
  # Called when the consumer has successfully
  # become a subscriber of this channel.
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    data["user"] = current_user.full_name
    data["time"] = Time.now.strftime('%H:%M')
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

Here we take the data coming in from the client
and add some more: the name of the current user and
the current time on the server.

The `broadcast` method will send the new data to 
all users subscribed to the chat-channel, even
the user who originally sent it.

### Client recieves data

In ``app/assets/javascripts/channels/chat.js`, where
we made the subscription, we add a function to handle
the received data:


```javascript
App.chatChannel = App.cable.subscriptions.create({
  channel: 'ChatChannel',
  room: 'main'}, 
  {
    received: function(data) {
      $("#output").append('<p>' + data['user'] + ': ' + data['body'] + '</p>');
    }
  }
);
```



Deployment
------



