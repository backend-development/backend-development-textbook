Authentication from Scratch
===========================

This guide is about Logins and Logouts.

After reading this guide you will

* understand how cookies, sessions, logins are connected
* be able to build a rails app with simple login and logout
* be able to use other authentication providers
* be able to offer password reminders to your users

------------------------------------------------------------

Sessions in Rails 
------------------

HTTP is a **stateless** protocol. This means that the web server
does not need to remember anything about the client from one
request to the next.  

Building a Login for your web app means getting around the
statlessness, creating a way for the web app to remember: oh, this is user
Susan, I already know her, she has these three things in her shopping cart
and is allowed to view this secret page.

Cookies are a way to achive statefulness in HTTP. A cookie
is an abitrary piece of information that the server sends to the
client, and that the client will echo back with every request.

![cookie set by rails,  as displayed by firebug](images/cookie-in-ff-inspector.png)

Web frameworks use cookies to offer so called **sessions** to the
developer: a session is a key-value store that is associated with
the cookie, and thus with one specific user.

Ruby on Rails by default sets a cookie named after the application.
In the above screenshot you can see the cookie set by the `wichteln`
application as displayed by firebug storage inspector, below the same cookie
in chrome developer tools.

![cookie set by rails,  as displayed by chrome](images/cookie-in-chrome.png)

If you copy over this cookie to another browser, you are getting access to
the session in that new browser!


When programming the backend In Ruby on Rails you 
find a Hash `session` that is accessible from
both controllers and views.

See [Rails Guide: Controller](http://guides.rubyonrails.org/action_controller_overview.html#session)
for more details.


Virtual Attributes 
--------------

When building your first rails app with the scaffolds generator
or the model generator you immediately see how tightly the
rails model is connected to the database table.

But there is more to the model than just that.  The model 
is a ruby class. You can use it to add the so called "business logic"
to your model:  for a model representing a book in the library
this would be methods for checking out and handing in the book, .... for
every model this will be different.

In many cases you want the object from your model class 
to have a different set of attributes than the underlying database has.
To achieve this disconnect we will look into virtual attributes 

In the following example the attribute `fullname`
is computed from two other attributes, and does not really
exist in the database:

``` ruby
attr_accessible :firstname, :lastname, :fullname

def fullname
  "#{firstname} #{lastname}"
end
```

To set the attribute 
is computed from two other attributes, does not really
exist in the database.

``` ruby
def fullname=(name)
  split = name.split(' ', 2)
  self.firstname = split.first
  self.lastname = split.last
end
```


See [Railscast no.16](http://railscasts.com/episodes/16-virtual-attributes?view=asciicast) for
more details on virtual attributes.


Password Storage
--------------

### has secure password

Rails comes with the following automatism for handling passwords,
which go a long way to following the [OWASP recommendations](https://www.owasp.org/index.php/Password_Storage_Cheat_Sheet).

It assumes that you have an attribute "password_digest"
in your database (and no attribute "password").

You can use it like this: Add the gem 'bcrypt' to the Gemfile, and
`has_secure_password` to your user model:

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
password twice, to make it less likely that typoes go through.
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



Login from Scratch
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

Now you can direct your browser to http://localhost:3000/login
Next you need to set up the view for the login form there: 

``` ruby
<!-- app/views/session/new.html.erb: -->

<h1>Log in</h1>

<%= form_tag login_path do |f| %>
    E-Mail:   <%= text_field_tag     :email    %> <br>
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
    par = login_params
    user = User.find_by(email: par[:email])
    if user && user.authenticate(par[:password])
      # Save the user id inside the browser cookie. 
      # This is how we keep the user # logged in 
      # when they navigate around our website.
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Logged in'
    else
      redirect_to login_path, alert: 'Log in failed'
    end
  end

  # deletes sesssion
  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: 'Logged out' 
  end

private

  def login_params
    params.permit(:email, :password)
  end
end
```

The helper_method `current_user` we define in 
the application controller.  If the user_id is not
set in the session or if the user with this id does not
exist (any more) we just return nil as the current_user.

app/app/controllers/application_controller.rb:

``` ruby
  def current_user
    @current_user ||= User.where(id: session[:user_id]).first if session[:user_id]
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

Login using twitter, facebook, github, ...
-----------

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

Omniauth is a "Rack Middleware". That means it is somewhat independant
of the rails app you are building.  It has access to the HTTP request, will
analyze that, and pass on data to your rails app through the environment variable `omniauth.auth`.

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
  match '/auth/:provider/callback', :to => 'sessions#create',  via: [:get, :post]
  match '/auth/failure',            :to => 'sessions#failure', via: [:get, :post]
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
    a = Authentication.find_or_create_by( provider: auth['provider'], uid: auth['uid'] )
    # save other info you want to remember:
    a.update( secret: auth["credentials"]["secret"],  token: auth["credentials"]["token"]  )
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

Confirmation E-Mail, Password Reminder, ...
-----------

If you want to stick with registering users in your own app
the gem `devise` offers a lot of features. It makes your logins ...

* Confirmable: sends emails with confirmation instructions and verifies whether an account is already confirmed during sign in.
* Recoverable: resets the user password and sends reset instructions.
* Registerable: handles signing up users through a registration process, also allowing them to edit and destroy their account.
* Rememberable: manages generating and clearing a token for remembering the user from a saved cookie.
* Trackable: tracks sign in count, timestamps and IP address.
* Timeoutable: expires sessions that have not been active in a specified period of time.
* Validatable: provides validations of email and password. It's optional and can be customized, so you're able to define your own validations.
* Lockable: locks an account after a specified number of failed sign-in attempts. Can unlock via email or after a specified time period.

Devise can also be combined with omniauth:

* Omniauthable: adds OmniAuth support.
