Authentication from Scratch
===========================

This guide is about Logins and Logouts.

After reading this guide you will

* understand how cookies, sessions, logins are connected
* be able to write a model is more than just the mapping of a database table
* be able to build simple authentication into your rails app

------------------------------------------------------------

Sessions in Rails 
------------------

HTTP is a **statless** protocol. This means that the web server
does not need to remember anything about the client from one
request to the next.  

Building a Login for your web app means getting around the
statlessness, creating a way for the web app to remember: oh, this is user
Susan, I already know her, she may look at this stuff.

Cookies are a way to achive statefulness in HTTP. A cookie
is an abitrary piece of information that the server sends to the
client, and that the client will echo back with every request.

Web frameworks use cookies to offer so called **sessions** to the
developer: a session is a key-value store that is associated with
the cookie, and thus with one specific user.

Ruby on Rails by default sets a cookie named after the application.
In the following screenshot you can see the cookie set by the `kanban`
application (as displayed by firebug):


![cookie set by rails,  as displayed by firebug](images/rails-cookie.png)

In Ruby on Rails you find a Hash `session` that is accessible from
both controllers and views.

See [Rails Guide: Controller](http://guides.rubyonrails.org/action_controller_overview.html#session)
for more details.



Models are more than a simple Database Mapping
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
For example in a user-model you want to be able to set the password,
and to check if it is correct, but you do not want to read out the password.
The methods might look like this:

``` ruby
def password=
end

def check_password( p )
end
```

When you look into the database, the password should be salted and encrypted.

To achieve this disconnect we will look into virtual attributes 

### Virtual Attribute: Getter and Setter

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
more details.


Login from Scratch
-----------

We now have all the bits and pieces to build a
Login.  

There is a rails convention for authentication systems:
the current user should be accessible via a helper method `current_user`.

### user-model for authentication

* Class User offers access login, email, firstname, lastname, password, password_confirmation
* Class User writes to Database:  firstname, lastname, email, login, crypted_password, salt

![Railscasts](images/railscast-auth-from-scratch.jpg)

There are two Railscasts on this subject:

* [Railscast no.250](http://railscasts.com/episodes/250-authentication-from-scratch?view=asciicast),
* revised as [Railscast no.385](http://railscasts.com/episodes/385-authorization-from-scratch-part-1?view=asciicast) + [Railscast no.386](http://railscasts.com/episodes/386-authorization-from-scratch-part-2?view=asciicast)


