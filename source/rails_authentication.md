Rails Authentication
===========================

This guide is about Logins and Logouts for your Rails app.

After reading this guide you will

* understand how cookies, sessions, logins are connected
* be able to build a rails app with simple login and logout
* be able to offer password reminders to your users
* be able to use other authentication providers

REPO: You can study the [code](https://github.com/backend-development/rails-example-kanban-board-login) and try out [the demos](https://kanban-1.herokuapp.com/) for the authentication examples described here.

------------------------------------------------------------

HTTP and Sessions
------------------

HTTP is a **stateless** protocol. This means that the protocol
does not require the web server to remember anything from one
request to the next.  So calling the same URL from different
clients will basically return the same result.

But this is not enough for many web apps we want to build: we
want certain pages to only be available to some users.  We want
to offer shopping carts or wizards that let a user complete
a complex action through several small steps, that carry over state.

![cookie set by rails,  as displayed by firebug](images/session-cart.jpg)

In an old style GUI application running on windows or mac it
is clear that that only one user is using the app at a time. We
can use variables in main memory to store information pertaining
to that user, and they will carry over through many interactions
(opening a new window of our app, clicking a button, selecting
something from a menu). 

In a web app this true for the front end of the app, in a very
restricted sense: If you set a variable in javascript it will only 
be available for this one user in this one webbrowser.  
But if the user leaves your app by typing in a new URL, 
or following a link or just reloading the page this information will be lost.


In the backend we need some way to identify that a certain
request comes from a certain user, and to "reattach" the state
to this request.  There are several ways to do this:

1. **HTTP Basic Authentication** according to [rfc 1945, section 11](https://tools.ietf.org/html/rfc1945#section-11): The browser sends (hashed) username and password to the server with each request. The HTTP Headers `Authorization: Basic ...` and `WWW-Authenticate: Basic ...` are used. The client sends the info automatically for every subsequent request to the server.
2. **HTTP Cookies** according to [rfc 6265](https://tools.ietf.org/html/rfc6265). The HTTP Header `Cookie` is used. The server sets the cookie, the client returns the cookie automatically for every subsequent request to the server.
3. **JSON-Token** according to [jwt.io](https://jwt.io/) / [rfc 7519](https://tools.ietf.org/html/rfc7519) use a can be used directly in HTTP with  `Authorization: Bearer ...` and `WWW-Authenticate: Bearer ...` or in an URL or as POST data 


### Security

If you use any of these methods over HTTP, unencrypted,
then an attacker might be able to steal the authentication information.
So always use HTTPS!

Both Authenticate-Headers and Cookies are sent automatically
by the browser each time you access the web app.  This can be used
exploited by [Cross Site Request Forgery attacks](https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)).

### Session in Backend Development

Web frameworks use any of the methods described above
to offer so called **sessions** to the
developer: a session is a key-value store that is associated with
the requests of one specific user.

Ruby on Rails by default sets a cookie named after the application.
In the screenshot below you can see the cookie set by the `kanban`
application as displayed by firefox develoepr tools in the
tab Storage.

![cookie set by rails, as displayed by firefox develoepr tools ](images/cookie-in-ff-inspector.png)

The cookie is set with the `HttpOnly` option, which means it cannot be
changed by JavaScript in the browser.  But it is still vunerable to a
replay attack: by using `curl` on the command line we can send a stolen
cookie with the HTTP request and will be 'logged in' for that request:

```
curl -v --cookie "_kanban_session=bWdwc...d4c; path=/; HttpOnly" https://kanban-2.herokuapp.com/
...
<span>Logged in as mariam <a href="/logout">logout</a>
```
This makes it all the more important that the cookie not be stolen!
Remember to always use https if your app authenticates users at
any point.

The Rails framework automatically sets and reads this cookie,
and offers a Hash `session` that is accessible from
both controllers and views.   By default the keys and values you store
in the session hash are serialized, encrypted with a secret key and 
sent as the value of the session cookie.

See [Rails Guide: Controller](http://guides.rubyonrails.org/action_controller_overview.html#session)
for more details.


Password Storage
--------------

When storing passwords in a web app there are a lot of things you
can do wrong: store the password as plain text, for example.

Rails comes with built in functions for handling passwords,
which go a long way to following the [OWASP recommendations](https://www.owasp.org/index.php/Password_Storage_Cheat_Sheet).

It assumes that you have an attribute "password_digest"
in your model (and no attribute "password"), and that you
have added 'bcrypt' to the Gemfile.

### has secure password

Add `has_secure_password` to your user model:

``` ruby
class User < ActiveRecord::Base
  has_secure_password
```

Now if you call 

``` ruby
User.create({username: "mariam", password: 'badpassword123' })
```

The password will be encrypted, and only the encrypted version
will be stored in the database.

It will add the `authenticate` method to your User model:

``` ruby
user = User.find(username: "USERNAME").authenticate("THE PASSWORD") 
```

The authenticate method will encrypt the password again, and compare
it to the password_digest in the database.  It will return nil if
the password does not match.

### validates confirmation of password

It is good UX practice to have users supply their
password twice, to make it less likely that typos go through.
Rails also helps you with this:  You can add `validates_confirmation_of :password`
to the user model:

``` ruby
class User < ActiveRecord::Base
    has_secure_password
    validates_confirmation_of :password
```

Now the create-method is changed again: you need to supply the
passwort twice to the create method:

``` ruby
User.create({username: "mariam",
    password: 'badpassword123',
    password_confirmation: 'badpassword1234'})
```

This use of create will not actually succeed, because the password_confirmation does
not match the password.


Basic Login
-----------

We now have all the bits and pieces to build a Login.  

There are some rails convention around this:

* the current user should be accessible via a helper method `current_user`,
* login in and login out is seen as "creating a session" and "deleting a session" and handled by restful routes,
* there is a session controller and some views, but no model!


Let's start by creating the routes:

``` ruby
# config/routes.rb:
  get  '/login'  => 'sessions#new'
  post '/login'  => 'sessions#create'
  get  '/logout' => 'sessions#destroy'
```

and the session controller to handle this routes:

``` bash
rails g controller sessions new create destroy
```

Now you can direct your browser to http://localhost:3000/login
Next you need to set up the view for the login form there: 

``` ruby
<!-- app/views/sessions/new.html.erb: -->

<h1>Log in</h1>

<%= form_tag login_path do |f| %>
    Username: <%= text_field_tag     :username %> <br>
    Password: <%= password_field_tag :password %> <br>
    <%= submit_tag 'Log In' %>
<% end %>
```

This form sends just two pieces of data: `email` and `password`.
So in the controller you have to extract these using `params.permit`.

If authentication goes through we store the user.id in the session.
Only the id is needed, we can load everything else from the database later.


app/app/controllers/sessions_controller.rb:

``` ruby
class SessionsController < ApplicationController

  # displays login form
  def new
  end

  # checks login data and starts session
  def create
    reset_session # prevent session fixation
    par = login_params
    user = User.find_by(username: par[:username])
    if user && user.authenticate(par[:password])
      # Save the user id in the session
      # rails will take care of setting + reading cookies
      # when the user navigates around our website.
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Logged in'
    else
      redirect_to login_path, alert: 'Log in failed'
    end
  end

  # deletes sesssion
  def destroy
    reset_session
    redirect_to root_path, notice: 'Logged out' 
  end

private

  def login_params
    params.permit(:username, :password)
  end
end
```

The helper_method `current_user` we define in 
the application controller.  If the user_id is not
set in the session or if the user with this id does not
exist (any more) we just return nil as the current_user.


``` ruby
<!-- app/app/controllers/application_controller.rb -->
def current_user
  @current_user = nil
  if session[:user_id]
    @current_user ||= User.where(id: session[:user_id]).first 
  end
end
helper_method :current_user
```


With the current_user helper method returning nil if
nobody is logged in we can also use it in the view
to display different things for logged in users and non logged in visitors:

``` ruby
<!-- app/views/layouts/application.html.erb -->
<% if current_user %> 
  Logged in as <%= current_user.name %> 
  <%= link_to "log out", logout_path %>
<% else %>
  <%= link_to "log in", login_path %>
  | <%= link_to "register", new_user_path %>
<% end %>
```

Devise
-----------

If your app deals with more then just one or two users
that you set up "by hand", the gem devise can help you a lot.
It can makes your logins ...

* Confirmable: sends emails with confirmation instructions and verifies whether an account is already confirmed during sign in.
* Recoverable: resets the user password and sends reset instructions.
* Registerable: handles signing up users through a registration process, also allowing them to edit and destroy their account.
* Rememberable: manages generating and clearing a token for remembering the user from a saved cookie.
* Trackable: tracks sign in count, timestamps and IP address.
* Timeoutable: expires sessions that have not been active in a specified period of time.
* Validatable: provides validations of email and password. It's optional and can be customized, so you're able to define your own validations.
* Lockable: locks an account after a specified number of failed sign-in attempts. Can unlock via email or after a specified time period.

See the [devise documentation](http://devise.plataformatec.com.br/#getting-started) on how to set it up.

When set up correctly devise gives you helper methods to use in your controllers and views:

* `current_user` 
* `user_signed_in?` # to check if a user is signed in (in views and controllers)
* `before_action :authenticate_user!` # to make a controller only accessible to authenticated users



Omniauth
---------------

In many scenarios it might be more convenient for your users
to not have to register on your site, but to use another service
to authenticate.  That way they don't have to remember another password.
And you might not have to handle passwords at all.

The gem `omniauth` helps you deal with OAuth2, OpenID, LDAP, and many
other authentication providers.  The [list of strategies](https://github.com/intridea/omniauth/wiki/List-of-Strategies)
is quite impressive.  Think carefully about what services your users
are using, and which services might be useful to your app: could
you use Dropbox to authenticate, and also to deliver data directly
to your users dropbox? Would it make sense to use facebook or twitter and also
send out messages that way?  


### Providers 

You will need the Gem `omniauth` and 
additional gems for each provider.  For example if you
want to use both github and stackoverflow for your web app geared
towards developers, you would need three gems:

```
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-stackoverflow'
```

You will have to register your app with the authentication
provider, eg. at [https://developers.facebook.com/apps/](https://developers.facebook.com/apps/) 
or [https://apps.twitter.com/](https://apps.twitter.com/).
For every provider you get two pieces of information: a key and a secret.
These you add to the configuration of omniauth:

``` ruby
# config/initializers/omniauth.rb:

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'TWITTER_KEY', 'TWITTER_SECRET'
end
```

If you plan on publishing your source code (e.g. because you use github for free ;-)
you might want to set these values in a way that is NOT saved to the repository.
You could use environment variables for that:

``` ruby
# config/initializers/omniauth.rb:

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
end
```

Then you can set the environment variables locally on the command line:

```sh
TWITTER_KEY=abc
TWITTER_SECRET=123
```

If you deploy to heroku, use the heroku command line interface to set
the variables there:

```sh
heroku config:set TWITTER_KEY=abc
heroku config:set TWITTER_SECRET=123
```

### Models

For authentication you need to save at least the provider and the uid in your database
somewhere.  But you can get more information out of the authentication:
name, e-mail, and the token and secret needed to actually use the service.

If you will only use one service, you can save the information directly
in the user model.  But it might be more prudent to plan for different authentication
methods, and create a separate Authentication model. This way you can
let users choose one of several authentication methods.

``` ruby
# created with
# rails g migration CreateAuthentication provider uid user:references token secret

class CreateAuthentication < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.string :provider
      t.string :uid
      t.references :user, index: true, foreign_key: true
      t.string :token
      t.string :secret
    end
  end
end
```

The `uid` is unique within each provider. There is only one
user with id `42` at twitter, but there might be a users with the
same desigation at facebook.


``` ruby
# app/model/authentication.rb
class Authentication < ActiveRecord::Base
  belongs_to :user  # also add has_many to users model!
  validates :provider, :uid, presence: true
  validates :uid, uniqueness: { scope: :provider }
end
```

### Login and Logout

Omniauth is a "Rack Middleware". That means it is somewhat independant
of the rails app you are building.  It has access to the HTTP request, will
analyze that, and pass on data to your rails app through the 
environment variable `omniauth.auth`.

To log in you send the user to `/auth/:provider` (e.g. `/auth/facebook`).

``` ruby
<!-- app/views/layouts/application.html.erb -->
  <% if current_user %> 
    Logged in as <%= current_user.name %> 
    <%= link_to "log out", logout_path %>
  <% else %>
    <%= link_to "log in with twitter", "/auth/twitter" %>
  <% end %>
```

This URL is handled by omniauth, not by your rails app.  omniauth will send
the users browser on to a URL at the provider.  There the user can log in. After
that the browser is redirected to your app again, to `/auth/:provider/callback`

This URL you need to map to the session controller:


``` ruby
# config/routes.rb:
match '/auth/:provider/callback', to: 'sessions#create',  via: [:get, :post]
match '/auth/failure',            to: 'sessions#failure', via: [:get, :post]
```

In the session controller you can now read the data that omniauth provides
from the environment variable.  As a first step you could just print it out,
to see what data is provided:

``` ruby
def create
  render :text => "<pre>" + env["omniauth.auth"].to_yaml and return
end
```

There are two basic cases to consider: either the user has logged in using
this authorisation method before (then we should find that in our database),
or they are logging in for the first time.

This can get quite involved, so we hide it away inside the user model:

``` ruby
def create
  user = User.find_or_create_with_omniauth( request.env['omniauth.auth'] )

  if user 
    session[:user_id] = user.id
    redirect_to root_path, notice: 'Logged in'
  else
    redirect_to login_path, alert: 'Log in failed'
  end
end
```

``` ruby
# app/model/user.rb

def self.find_or_create_with_omniauth(auth)
  # look for an existing authorisation 
  # provider + uid uniquely identify a user
  a = Authentication.find_or_create_by( 
         provider: auth['provider'], 
         uid:      auth['uid'] 
  )
  # save other info you want to remember:
  a.update( secret: auth["credentials"]["secret"],  
            token:  auth["credentials"]["token"]  )
  a.save!
  
  if a.user.nil? 
    # all new user
    u = create! do |user|
      user.uid      = auth["uid"]
      user.name     = auth["info"]["name"]
    end

    a.user = u
    a.save!
  end

  return a.user
end # def self.find_or_create_with_omniauth(auth)
```

The method `find_or_create_by` handles both cases in one: either it
finds an existing authentication or it creates a new one.


Devise can also be combined with omniauth:

* Omniauthable: adds OmniAuth support.

Further Reading
-------

* OmniAuth [wiki](https://github.com/intridea/omniauth/wiki)
* Devise [github page](https://github.com/plataformatec/devise)
* Rails Security Guide on [User Management](http://guides.rubyonrails.org/security.html#user-management)
