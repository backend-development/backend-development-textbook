APIs
=====

After working through this guide you will:

* know about the thinking behind REST APIs and JSON API
* be able to configure your existing controllers to offer resources as JSON
* be able to set up an API for your rails app that is separate from existing controllers

REPO: You can study the [code](https://github.com/backend-development/api_sample_app) and try out [the demo](https://dry-cove-38472.herokuapp.com/) for the example described here.

---------------------------------------------------------------------------

## What is an API

API stands for "Application Programming Interface". It is a set of clearly defined methods 
of communication with a software component. So the objects and methods exposed by a library
form an API, for example the 

In Web development the acronym API is most
commonly used when the software component in question runs on a different server on the
Internet and is accessed via the network.  

This Guide is concerned with APIs that you build and run using Ruby on Rails.

## REST

The acronym REST was coined by Roy Fielding in his dissertation. When describing
the architecture of the web, and what made it so successfull on a technical level,
he desribed this architecture as "Representational State Transfer" (REST).

This Acronym was later picked up to describe a certain style of API,
and to distiguish such APIs from SOAP APIs.

A REST API allows to access and manipulate textual representations of Web resources using HTTP Methods and stateless operations. 

"Web resources" were first defined on the World Wide Web as documents or files identified by their URLs, but today they have a much more generic and abstract definition encompassing every thing or entity that can be identified, named, addressed or handled, in any way whatsoever, on the Web.


[Tilkov(2007)](https://www.infoq.com/articles/rest-introduction) gives a brief introduction to REST.  The main points are:

1. Give every resource a  unique URL
2. “Hypermedia as the engine of application state” (HATEOAS) - use URLs to reference other resources (not just ids)
3. Use HTTP Methods (and Status Codes) as intended. 
4. One resource can have multiple representations, for example HTML, JSON and XML
5. Communicate statelessly - if possible!



### URLS

Give every resource a  unique URL.
Please note that REST does not demand a certain form of URL.
While URLs with no parameters are often used:

```
https://example.com/users/
https://example.com/users/1/
https://example.com/users/2/
https://example.com/users/3/
```

it is just as restful to use parameters:

```
https://example.com/users.php
https://example.com/users.php?id=1
https://example.com/users.php?id=2
https://example.com/users.php?id=3
```

In REST, the URLs correspond to resources, which are represented by nouns.
This is a difference to SOAP, there there is typically just one endpoint:


```
https://example.com/soap/router/
```

Through this endpoint you can access methods like `getUserData()` or `deleteUser()`. 




### HATEOAS


“Hypermedia as the engine of application state”  means that a client interacts with a network application entirely through hypermedia, and needs no prior knowledge of URLs.

If an API returns the following JSON:

```
{
    "id": "1",
    "name": "Example User",
    "email": "example@railstutorial.org"
    "profile_pics": [ 2, 5 ]
}
```

Then the Client needs to know how to get profile_pics from the API.
For example because the developer read the docs.

HATEOAS demands that the full URL is used to refer to other resources:

```
{
    "id": "1",
    "name": "Example User",
    "email": "example@railstutorial.org"
    "profile_pics": [ 
       "https://sample.com/api/profile/pictures/2", 
       "https://sample.com/api/profile/pictures/5"
    ]
}
```


### HTTP Methods and Status Codes

Use HTTP Methods (and Status Codes) as intended.  

Regarding the HTTP Methods there are two important distinctions:

* the GET and HEAD methods should take no other action than retrieval. These methods ought to be considered **safe**.
* The methods GET, HEAD, PUT and DELETE are idempotent: repeating the request will not change the end result (aside from error or expiration issues)

The definition of the [Methods](https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html) in HTTP1.0 is just a short read, and worth its while!


References for status codes:

* [Status codes](https://httpstatuses.com/422)
* [Status cats](https://http.cat/)


When buidling a REST API, the HTTP Protocol already defines a lot
about that API. There is no need to come up with a way to delete
a resource, or to indicate failure. HTTP already offers the DELETE method
and status codes that indicate errors.

### Multiple Representations

The same resource can be available in different formats.
There are two common ways of requesting different formats:

With the HTTP Header `Accept`:


```
GET /mini/person/83 HTTP/1.1
Host: example.com 
Accept: application/xml
```

Or by adding an "extension" as part of the URL:

```
http://example.com/mini/person/83.html
http://example.com/mini/person/83.xml
http://example.com/mini/person/83.json
```

The three different versions of person number 83 might look
like this: the HTML web page:


```
<h1>Details zu einer Person</h1>
<p><img src="http://example.com/mini/profil/edvard_1_2.jpg" />
Herr Edvard Paul Beisteiner hat insgesamt 4 Werke in dieser Datenbank.
Er hat den Usernamen fhs14287.</p>
<ul>
  <li><a href='http://example.com/mini/werk/24'>The Thin Red Line</a></li>
  <li><a href='http://example.com/mini/werk/50'>Der böse Wolf</a></li>
  <li><a href='http://example.com/mini/werk/83'>nimm zwei, schatz</a></li>
  <li><a href='http://example.com/mini/werk/303'>the neighbour.</a></li>
</ul>
```

For an API the same resource might be represented as XML:

```
<person>
  <image ref='http://example.com/mini/profil/edvard_1_2.jpg' />
  <vorname>Edvard</vorname>
  <nachname>Beisteiner</nachname>
  <username>fhs14287</username>
  <werke>
    <werk ref='http://example.com/mini/werk/24'>The Thin Red Line</werk>
    <werk ref='http://example.com/mini/werk/50'>Der böse Wolf</werk>
    <werk ref='http://example.com/mini/werk/83'>nimm zwei, schatz</werk>
    <werk ref='http://example.com/mini/werk/303'>the neighbour.</werk>
  </werke>
</person>

```

or as JSON:

```
{"image":"http://example.com/mini/profil/edvard_1_2.jpg",
 "vorname":"Eduard",
 "nachname":"Beisteiner",
 "werk":[
    {"titel":"The Thin Red Line",
     "url":"http://example.com/mini/werk/24"},
    {"titel":"Der böse Wolf",
     "url":"http://example.com/mini/werk/50"},
    {"titel":"nimm zwei, schatz",
     "url":"http://example.com/mini/werk/83"},
    {"titel":"the neighbour.",
     "url":"http://example.com/mini/werk/303"}]}

```



### Statelessness


 Tilkov wirtes: "REST mandates that state be either turned into resource state, or kept on the client. In other words, a server should not have to retain some sort of communication state for any of the clients it communicates with beyond a single request."

 This is important for performance and scalability and performance.  
 Statelessness makes caching easy.  And in a scenario with serveral
 servers behind a load balancer, not having state on the server means
 the application will work if the requests bei one client are routest
 to different servers.


## JSON API


When an API returns JSON data this could take many forms.
The [json:api specification](http://jsonapi.org/) is a well thought out
convention for this.  

It is especially good with the HATEOS aspect of REST.

The json:api specification adhers to this principle.


Rendering JSON
---------

Rails is equipped to not just create HTML as output, but to easily
offer other representations as well.  

When you look at `rails routes` you can see that the routes created by
`resource :user` could contain an optional `format`:

```
                 Prefix Verb   URI Pattern                           Controller#Action
                   root GET    /                                     static_pages#home
                  users GET    /users(.:format)                      users#index
                   user GET    /users/:id(.:format)                  users#show
```

Only HTML is implemented by default. But we could use this feature
to have other formats:

* `/users` 
* `/users.json` 
* `/users.xml` 
* `/users/1` 
* `/users/1.json` 
* `/users/1.xml` 

When you try out accessing `/users/1.json` you get a response:


```
406 Not Acceptable
Content-Length: 39
Content-Type: application/json; charset=utf-8

{"status":406,"error":"Not Acceptable"}
```

This error message is meant for a
client expecting JSON data.  It uses both the HTTP status code
and the JSON to indicate the error.

### API for the sample app

The "Frontend 1" in the example app expects a very simple JSON structure:

To display one user, it loads from `/user/1.json` and expects
a single JSON object with three attributes:

```
{
   "id":1,
   "name":"Example User",
   "email":"example@railstutorial.org"
}
```


To display the table of users, it loads from `/users.json` and
expects a JSON array of objects like above:

```
[
  {
    "id":2,
    "name":"Precious Heaney",
    "email":"example-1@railstutorial.org"
  },
  {
    "id":3,
    "name":"Warren Considine Sr.",
    "email":"example-2@railstutorial.org"
  }
]
```

### creating JSON with erb


We could create views using erb in `app/views/users/show.json.erb`:

```
{
  "id": <%= @user.id %>,
  "name": "<%= @user.name %>",
  "email": "<%= @user.email %>"
}
```

and `app/views/users/index.json.erb`:

```
[
<% 
  @users.each_with_index do |user| %>
  {
    "id": <%= user.id %>,
    "name": "<%= user.name %>",
    "email": "<%= user.email %>"
  },
<% end %>
]
```

But wait, there's a problem: there is a comma after each object,
but there should be no comma after the last.

```
[
<% 
  max = @users.length - 1
  @users.each_with_index do |user,i| %>
  {
    "id": <%= user.id %>,
    "name": "<%= user.name %>",
    "email": "<%= user.email %>"
  }
  <%= if i < max then ',' end %>
<% end %>
]
```

### creating JSON with jbuilder

Formatting JSON would get quite repetitive if we need to create views for several resources.
We have not even touched on the problem of escaping: what happens
if a users name contains a quote?  For example <kbd>Jack "the Ripper"</kbd>.
That would break our current view.

Rails 5 comes with the gem `jbuilder` which helps you create JSON, and
which handles all the escaping and formatting correctly.

We need to name the view `app/views/users/show.json.jbuilder`, 
and then can use the the following code to extract three properties
from the user object:

```
json.id @user.id
json.name @user.name
json.email @user.email
```

There is also a shorthand for this: 

```
json.extract! @user, :id, :name, :email
```

For the index view we want to create a JSON array. 
In `app/views/users/index.json.jbuilder` we write:

```
json.array! @users do |user|
  json.extract! user, :id, :name, :email
end
```


### authentication

All the authentication and access control we built into the
rails app before is still applicable to the JSON views.

In fact the scaffold generator always adds handling JSON responses
to the create, update and destroy actions of a controller.

For handling just HTML only this code would be needed:

```
  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user, notice: 'User was successfully created.' 
    else
      render :new 
    end
    end
  end
```

But the scaffold generator also adds `resond_to` and `format` commands,
to handle json differently from html:

```
  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
```



Stand Alone API
---------

To create a stand alone API we define new, separate routes under `/api/v1`.


```
namespace :api do
  namespace :v1 do
    resources :users, only: [:index, :create, :show, :update, :destroy]
  end
end
```

we will be using the `active_model_serializers` gem for creating jsonapi:

```
gem 'active_model_serializers'
```

this gem needs an initizalizer `config/initializers/active_model_serializers.rb`

```
require 'active_model_serializers/register_jsonapi_renderer'

ActiveModelSerializers.config.adapter = :json_api
```


### JSONAPI for the sample app

The "Frontend 2" in the example app expects the json to be formed
according to the json api specification.

`/api/v1/user/1` will return data about one resource:

```
{

    "data": {
        "id": "1",
        "type": "users",
        "attributes": {
            "name": "Example User",
            "email": "example@railstutorial.org"
        }
    }

}
```


`/api/v1/users/` returns an array, but the top level JSON structure
is an object with on attribute `data`:

```
{

    "data": [
        {
            "id": "2",
            "type": "users",
            "attributes": {
                "name": "Precious Heaney",
                "email": "example-1@railstutorial.org"
            },
        },
        ...
    ]
}
```

### creating JSON with active_model_serializers

After we defined the routes, we next need to create a controller.
As we are setting up a new hierarchy of controllers that will only
concerned with the API, it makes sense to inhert from `ActionController::API`, 
not from `ActionController::Base`.

All the "normal" controllers first inhert from `ApplicationController`. We
will build a similar structure for the api controllers, the will inhert from
`Api::V1::BaseController`:


```
# app/controllers/api/v1/base_controller.rb

class Api::V1::BaseController < ActionController::API
end
```

The users controller is the one that's actually called by the route:

```
# app/controllers/api/v1/users_controller.rb

class Api::V1::UsersController < Api::V1::BaseController
  def show
    user = User.find(params[:id])

    render jsonapi: user, serializer: Api::V1::UserSerializer
  end
end
```

The controller loads the right model, and then calls a **serializer** to
do the actual rendering of the json data.

The serializer needs to be defined in a separate file:

```
# app/serializers/api/v1/user_serializer.rb

class Api::V1::UserSerializer < ActiveModel::Serializer
  attributes(:name, :email)
end
```


# Documenting an API



See Halliday(2016): [Producing Documentation for Your Rails API](https://blog.codeship.com/producing-documentation-for-your-rails-api/) for a discussion of automatic methods of documentation generation.



See Also
--------


* [Fielding, Roy(2000): Architectural Styles and the Design of Network-based Software Architectures](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm). Dissertation. University of California/Irvine, USA.
* [Fowler (2010): Richardson Maturity Model](https://martinfowler.com/articles/richardsonMaturityModel.html)
* [Tilkov(2007): A Brief Introduction to REST](https://www.infoq.com/articles/rest-introduction)
* [Rails Guide: Rendering JSON in Action Controller Overview](http://edgeguides.rubyonrails.org/action_controller_overview.html#rendering-xml-and-json-data)
* [Rails Guide: Using Rails for API-only Applications](http://edgeguides.rubyonrails.org/api_app.html)
* [Vasilakis(2017): Rails 5 API Tutorial](https://github.com/vasilakisfil/rails5_api_tutorial)
* [Methods HTTP/1.0](https://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html) 
* [Status codes](https://httpstatuses.com/422)
