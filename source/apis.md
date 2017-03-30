APIs
=======================

After working through this guide you will:

* know about the thinking behind REST APIs and JSON API
* be able to configure your existing controllers to offer resourses as JSON
* be able to set up an API for your rails app that is separate from existing controllers

REPO: You can study the [code](https://github.com/backend-development/api_sample_app) and try out [the demo](https://dry-cove-38472.herokuapp.com/) for the example described here.

---------------------------------------------------------------------------

What is an API
---------------


## REST

The acronym REST was coined by Roy Fielding in his dissertation. When describing
the architecture of the web, and what made it so successfull on a technical level,
he desribed this architecture as "Representational State Transfer".

A REST API allows to access and manipulate textual representations of Web resources using a uniform and predefined set of stateless operations. 

"Web resources" were first defined on the World Wide Web as documents or files identified by their URLs, but today they have a much more generic and abstract definition encompassing every thing or entity that can be identified, named, addressed or handled, in any way whatsoever, on the Web.


## JSON API


When an API returns JSON data this could take many forms.
The [json:api specification](http://jsonapi.org/) is a well thought out
convention for this.  

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
and the JSON to indigate an error.


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


Formatting JSON would get quite repetitive if we need
to create views for several resources. 
Rails 5 comes with the gem `jbuilder` which helps you
create JSON. 


in `app/views/users/show.json.jbuilder`:

```
json.id @user.id
json.name @user.name
json.email @user.email
```

or, shorter:

```
json.extract! @user, :id, :name, :email
```


in `app/views/users/index.json.jbuilder`:
```
json.array! @users do |user|
  json.extract! user, :id, :name, :email
end
```




Stand Alone API
---------


See Also
--------


* [Rails Guide: Rendering JSON in Action Controller Overview](http://edgeguides.rubyonrails.org/action_controller_overview.html#rendering-xml-and-json-data)
* [Rails Guide: Using Rails for API-only Applications](http://edgeguides.rubyonrails.org/api_app.html)
* [Fielding, Roy(2000): Architectural Styles and the Design of Network-based Software Architectures](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm). Dissertation. University of California/Irvine, USA.
* [Tilkov(2007): A Brief Introduction to REST](https://www.infoq.com/articles/rest-introduction)
