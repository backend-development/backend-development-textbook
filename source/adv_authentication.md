# Advanced Authentication

This guide is about Authentication for Web and Mobile
Apps. 

After reading this guide you will

- have an overview of scenarios and authentication methods
- be able to build a rails app that uses other authentication providers with OAuth
- be able to build a rails app with JWT

REPO: You can study the [code](https://github.com/backend-development/rails-example-kanban-board-login) and try out [the demos](https://kanban-1.herokuapp.com/) for the authentication examples described here.

---

## Authentication + Authorisation Scencarios

Some questions to ask yourself:

* Do I only need authentication (Is this the user?) or also authorisation (which user may access what?)
* Is one factor enough?  Do I want to support 2 factor athentication?
* Who does the authentication? My own app or another "authentication provider"?
* Which programs need to authenticate? Browsers? Native apps? Command line programs?
* Are users expecting a "single sign on"?

### Authentication and Authorisation

This is epecially intresting when my app wants to access
data in another app.  For example:  Authenticate via github, and also
access the users private repositories.  Authenticate via google and also
access the users photos. 

### Two Factor Authentication

any combination of:

*  Something you know - a password or a pin
*  Something you have -   mobile phone or a security token like a [YubiKey](https://www.yubico.com/products/#yubikey-5ci)
*  Something you are - fingerprint, retina scan, FaceID
*  Something you do - typing speed, locational information etc.

### Different types of programs

Browsers do Cookies, other types of programs do not.

Command Line Authentication Flow:

![Command Line](images/office-cli-1.png)
![Command Line](images/cli-login-3.png)
![Command Line](images/cli-login-4.png)
![Command Line](images/cli-login-5.png)
![Command Line](images/office-cli.png)


### How to add state to HTTP

When thinking about Authentication and Web Applications we
first have to overcome the stateless nature of HTTP.
There are several ways to do this:

1.  **HTTP Basic Authentication** according to [rfc 1945, section 11](https://tools.ietf.org/html/rfc1945#section-11): The server sends a `WWW-Authenticate: Basic ...` header in the first response. The browser asks the user for username and password, and then sends the (hashed) username and password to the server with subsequent request using the HTTP Headers `Authorization: Basic ...`.
2.  **HTTP Cookies** according to [rfc 6265](https://tools.ietf.org/html/rfc6265). The server sets the cookie (using the Header 'Set-Cookie'), the client returns the cookie automatically for every subsequent request to the server (using the HTTP Header `Cookie`).
3.  **Bearer-Token**, with  `Authorization: Bearer ...` and `WWW-Authenticate: Bearer ...`

## Web Authentication

A relatively new Method: the browser keeps tracks of private keys,
uses public key to log in on server. Implemented in Browsers since 2018, 2019.
See [Guide](https://webauthn.guide/) and [Demo](https://webauthn.io/).

<video class="wp-video-shortcode" id="video-2462-3_html5" poster="images/webauthn-android-fennec.png" loop="1" preload="metadata" style="width: 400px; height: 710.667px;" src="images/webauthn-android-fennec-1.mp4" width="400" height="711"><source type="video/mp4" src="images/webauthn-android-fennec-1.mp4?_=3"><source type="video/webm" src="images/webauthn-android-fennec-1.webm"><a href="images/webauthn-android-fennec-1.mp4">images/webauthn-android-fennec-1.mp4</a></video>

## OAuth

Standard for requesting Authentication and Authorization from
a priovider.  Slightly different implmentations, [OpenID Connect](https://openid.net/connect/)
as additional specification makes using it simpler?

## JWT

Cookies work best when the only clients are browsers (and not native apps),
and when the frontend and the backend are hosted on the same domain.

**JSON-Web-Token** are used for more complex scenarios.
They offer the flexibility to use many transmission methods:

- HTTP-Headers  `Authorization: Bearer ...` and `WWW-Authenticate: Bearer ...`
- Parameter in an URL
- POST data

[jwt.io](https://jwt.io/) / [rfc 7519](https://tools.ietf.org/html/rfc7519)

### Encoding a Token

A JWT consists of three parts: header, payload and signature.
All three are encoded and concatenated with a dot. The result
looks like this (if you color-code it):

![](images/encoded-jwt3.png)

The encoding consists of two steps:  

* with [Base64](https://en.wikipedia.org/wiki/Base64#Examples)
endcoding the input string is converted to a new, longer string of only 64 characters
that are considered "save" for transfer via (ASCII only) e-mail.  Three bytes of the original are encoded into 4 bytes in 
the resulting string.  Base64 encoded strings may contain plus signs and are
padded with equal signs at the end. 
* As a second step the plus signs are replaced by minus signs and
the padding is dropped, resulting in a string that can be used in a URL without problems:

```
{ "msg_en": "Hello",
  "msg_jp": "こんにちは"
  "msg_de": "Guten Tag" }

eyAibXNnX2VuIjogIkhlbGxvIiwKICAibXNnX2pwIjogIuOBk+OCk+OBq+OBoeOBryIKICAibXNnX2RlIjogIkd1dGVuIFRhZyIgfQ==

eyAibXNnX2VuIjogIkhlbGxvIiwKICAibXNnX2pwIjogIuOBk-OCk-OBq-OBoeOBryIKICAibXNnX2RlIjogIkd1dGVuIFRhZyIgfQ
```

You can use the [JWT Debugger](https://jwt.io/#debugger-io) to decode this.

![](images/jwt-debugger.png)


### Structure of a Token




## Rails and OAuth

In many scenarios it might be more convenient for your users
to not have to register on your site, but to use another service
to authenticate. That way they don't have to remember another password.
And you might not have to handle passwords at all.

The gem `omniauth` helps you deal with OAuth2, OpenID, LDAP, and many
other authentication providers. The [list of strategies](https://github.com/intridea/omniauth/wiki/List-of-Strategies)
is quite impressive. Think carefully about what services your users
are using, and which services might be useful to your app: could
you use Dropbox to authenticate, and also to deliver data directly
to your user's dropbox? Would it make sense to use Facebook or Twitter and also
send out messages that way? Or are your users very privacy conscious and
want to avoid Facebook and Google?

### Providers

You will need the Gem `omniauth` and
additional gems for each provider. For example if you
want to use both Github and Stackoverflow for your web app geared
towards developers, you would need three gems:

```
gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-stackoverflow'
```

§

You need to register your app with the authentication
provider, eg. at [https://developers.facebook.com/apps/](https://developers.facebook.com/apps/)
or [https://apps.twitter.com/](https://apps.twitter.com/).
You have to specify the URL of your web app, and a callback URL:

![oauth app configuration](images/oauth-app-config.png)

There might also be a review process involved which might take
a few business days to go through.

§

You get back two pieces of information: a key and a secret.
In Twitter this looks like this:

![facebook app configuration](images/oauth-app-secret.png)

(A word of warning: if you change the configuration in `developers.facebook.com` then
you will get a new key and secret!)

You need to add the key and the secret to the configuration of omniauth:

```ruby
# config/initializers/omniauth.rb:

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'TWITTER_KEY', 'TWITTER_SECRET'
end
```

§

If you plan on publishing your source code
you might want to set these values in a way that is NOT saved to the repository.
You could use environment variables for that:

```ruby
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

If you deploy to heroku or dokku, use the command line interface to set
the variables there:

```sh
heroku config:set TWITTER_KEY=abc
heroku config:set TWITTER_SECRET=123

dokku config:set TWITTER_KEY=abc
dokku config:set TWITTER_SECRET=123
```

### Models

For authentication you need to save at least the provider name and the uid in your database
somewhere. In the simplest case you just save them in a user model:

```shell
rails g model user provider uid
```

To use additional services and get additional info from the provider
you also need to save a per-user token and secret:

```shell
rails g model user provider uid token secret
```

If you want to enable that one user can log in via different
providers and still be recognised as the same user, you need to
create a user model with a has_many relationship to an authentiation model
that stores provider and uid.

But we will stick to the simple version:

```ruby
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.timestamps
    end
  end
end
```

### Login and Logout

Omniauth is a "Rack Middleware". That means it is somewhat independent
of the Rails app you are building. It has access to the HTTP request, will
analyze that, and pass on data to your Rails app through the
environment variable `omniauth.auth`.

To log in you send the user to `/auth/:provider` (e.g. `/auth/facebook`).

```ruby
<!-- app/views/layouts/application.html.erb -->
  <% if current_user %>
    Logged in as <%= current_user.name %>
    <%= link_to "log out", logout_path %>
  <% else %>
    log in with <%= link_to "twitter", "/auth/twitter" %>
  <% end %>
```

§

This URL is handled by omniauth, not by your Rails app. Omniauth will send
the user's browser on to a URL at the provider. There the user can log in. After
that the browser is redirected to your app again, to `/auth/:provider/callback`

This URL you need to map to a session controller:

```ruby
# config/routes.rb:
match '/auth/:provider/callback', to: 'sessions#create',  via: [:get, :post]
match '/auth/failure',            to: 'sessions#failure', via: [:get, :post]
```

In the session controller you can now read the data that omniauth provides
from the environment variable.

§

As a first step you could just print it out,
to see what data is provided:

```ruby
def create
  render text: "<pre>" + env["omniauth.auth"].to_yaml and return
end
```

The data always contains values for `provider` and `uid` at the
top level. There may be a lot more data.

§

Here some example data from a twitter login:

```
provider: twitter
uid: '8506142'
info:
  nickname: bjelline
  name: Brigitte Jellinek
  ...
```

§

Now let's look at `session#create`:
There are two basic cases to consider: either the user has logged in using
this authorisation method before (then we should find them in our database),
or they are logging in for the first time.

This can get quite involved, so we hide it away inside the user model:

```ruby
def create
  user = User.find_or_create_with_omniauth(request.env['omniauth.auth'])

  if user
    session[:user_id] = user.id
    redirect_to root_path, notice: 'Logged in'
  else
    redirect_to login_path, alert: 'Log in failed'
  end
end
```

§

In the model we pick apart the information from omniauth:

```ruby
# app/model/user.rb

def self.find_or_create_with_omniauth(auth)
  # look for an existing authorisation
  # provider + uid uniquely identify a user
  User.find_or_create_by!(
    provider: auth['provider'],
    uid:      auth['uid']
  )
end
```

The ActiveRecord method `find_or_create_by` handles both cases in one: either it
finds an existing user or it creates a new one.

§

We don't really have a name for each user, but
we can fake that in the model:

```ruby
# app/model/user.rb
def name
  "#{uid}@#{provider}"
end
```

## Rails and JWT


### Adding JWT to Rails

`bundler add jwt` and restart the server.







## Further Reading

- OmniAuth [wiki](https://github.com/intridea/omniauth/wiki)
- Devise [github page](https://github.com/plataformatec/devise)
- Rails Security Guide on [User Management](https://guides.rubyonrails.org/security.html#user-management)
- [devise_token_auth](https://github.com/lynndylanhurley/devise_token_auth) for token based authentication for API only Rails apps
- [10 Things You Should Know about Tokens](https://auth0.com/blog/ten-things-you-should-know-about-tokens-and-cookies/)
