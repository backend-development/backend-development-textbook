Authentication from Scratch
===========================

This guide is about Logins and Logouts.

After reading this guide you will

* understand how cookies, sessions, logins are connected
* be able to build simple authentication into your rails app

------------------------------------------------------------

Code Reuse in Rails
-------------------

### views in views in views

* `app/views/layout/application.html.erb`  - the whole HTML document
* `app/views/<controllername>/<actionname>.html.erb` - the specific view
* `app/views/<controllername>/_form.html.erb` partial used by edit and new action
* `app/views/<controllername>/_*.html.erb` other partials you can create




### code reuse in views 

* `app/helpers/application_helper.rb` code you want to use in many views

### code reuse in controllers: filter

* `before_filter <methodname>`
* method is called before every action
* `before_filter <methodname>, :only => [:show, :edit, :update]`
* method is only called before the specified actions


### code reuse in controllers: inheritance

* all your controller inherti from `app/controllers/application_controller.rb` 
* only the ApplicationController inherits from ActionController::Base
* = one class to configure things such as request forgery protection and filtering of sensitive request parameters.  



Sessions in Rails 
------------------

* HTTP is stateless
* cookies added to make it stateful 
* result: sessions
* in Rails: hash `sessions` available in controllers + views
* See [Rails Guide: Controller](http://guides.rubyonrails.org/action_controller_overview.html#session)


### models are more than a simple Object <-> Database Mapping

* business logic
* offer a different interface than the database!
* "virtual attributes"

### virtual attribute: getter

is computed from two other attributes, does not really
exist in the database.

``` ruby
def fullname
  [first_name, last_name].join(' ')
end
```


### virtual attribute: setter

is computed from two other attributes, does not really
exist in the database.

``` ruby
def full_name=(name)
  split = name.split(' ', 2)
  self.first_name = split.first
  self.last_name = split.last
end
```


### virtual attributes

see [Railscast #16](http://railscasts.com/episodes/16-virtual-attributes?view=asciicast)




### user-model for authentication

* Class User offers access login, email, firstname, lastname, password, password_confirmation
* Class User writes to Database:  firstname, lastname, email, login, crypted_password, salt



See [Railscast #250](http://railscasts.com/episodes/250-authentication-from-scratch?view=asciicast)
