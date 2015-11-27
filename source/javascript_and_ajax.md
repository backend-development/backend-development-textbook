JavaScript and AJAX in Rails
================================

This guide covers the built-in Ajax/JavaScript functionality of Rails; 
it will enable you to create rich and dynamic Ajax applications with
ease!

After reading this guide, you will know:

* The basics of Ajax.
* Unobtrusive JavaScript.
* How Rails' built-in helpers assist you.
* How to handle Ajax on the server side.
* The Turbolinks gem.

This guide is based on the original
[Rails Guide Working with JavaScript](http://guides.rubyonrails.org/working_with_javascript_in_rails.html).
The original guide uses coffeescript, this guide uses ES6 and
refers to an [example app](https://github.com/backend-development/rails-example-recipes-js)

-------------------------------------------------------------------------------

An Introduction to Ajax
------------------------

In order to understand Ajax, you must first understand what a web browser does
normally.

When you type `http://localhost:3000` into your browser's address bar and hit
'Go,' the browser (your 'client') makes a request to the server. It parses the
response, then fetches all associated assets, like JavaScript files,
stylesheets and images. It then assembles the page. If you click a link, it
does the same process: fetch the page, fetch the assets, put it all together,
show you the results. This is called the 'request response cycle.'

JavaScript can also make requests to the server, and parse the response. It
also has the ability to update information on the page. Combining these two
powers, a JavaScript writer can make a web page that can update just parts of
itself, without needing to get the full page data from the server. This is a
powerful technique that we call Ajax.

Rails provides quite a bit of built-in support for building web pages with this
technique. You rarely have to write this code yourself. The rest of this guide
will show you how Rails can help you write websites in this way, but it's
all built on top of this fairly simple technique.

Unobtrusive JavaScript
-------------------------------------

Rails uses a technique called "Unobtrusive JavaScript" to handle attaching
JavaScript to the DOM. This is generally considered to be a best-practice
within the frontend community, but you may occasionally read tutorials that
demonstrate other ways.

Here's the simplest way to write JavaScript. You may see it referred to as
'inline JavaScript':

```html
<a href="#" onclick="this.style.backgroundColor='#990000'">Paint it red</a>
```
When clicked, the link background will become red. Here's the problem: what
happens when we have lots of JavaScript we want to execute on a click?

```html
<a href="#" onclick="this.style.backgroundColor='#009900';this.style.color='#FFFFFF';">Paint it green</a>
```

Awkward, right? We could pull the function definition out of the click handler,
and turn it into JavaScript:

```js
  function paintIt (element, backgroundColor, textColor) {
    element.style.backgroundColor = backgroundColor;
    if (textColor != null) {
      return element.style.color = textColor;
    }
  }
```

And then on our page:

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
```

That's a little bit better, but what about multiple links that have the same
effect?

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
<a href="#" onclick="paintIt(this, '#009900', '#FFFFFF')">Paint it green</a>
<a href="#" onclick="paintIt(this, '#000099', '#FFFFFF')">Paint it blue</a>
```

Not very DRY, eh? We can fix this by using events instead. We'll add a `data-*`
attribute to our link, and then bind a handler to the click event of every link
that has that attribute:

```js
  function paintIt(element, backgroundColor, textColor) {
    element.style.backgroundColor = backgroundColor;
    if (textColor != null) {
      return element.style.color = textColor;
    }
  };

  $(document).on("page:change",
    $("a[data-background-color]").click(function(e) {
      var backgroundColor, textColor;
      e.preventDefault();
      backgroundColor = $(this).data("background-color");
      textColor = $(this).data("text-color");
      paintIt(this, backgroundColor, textColor);
    });
  });
```
```html
<a href="#" data-background-color="#990000">Paint it red</a>
<a href="#" data-background-color="#009900" data-text-color="#FFFFFF">Paint it green</a>
<a href="#" data-background-color="#000099" data-text-color="#FFFFFF">Paint it blue</a>
```

We call this 'unobtrusive' JavaScript because we're no longer mixing our
JavaScript into our HTML. We've properly separated our concerns, making future
change easy. We can easily add behavior to any link by adding the data
attribute. We can run all of our JavaScript through a minimizer and
concatenator. We can serve our entire JavaScript bundle on every page, which
means that it'll get downloaded on the first page load and then be cached on
every page after that. Lots of little benefits really add up.

Take a look at the standard "destroy" links created by the scaffold:
they use `data-confirm` to unobstrusively add a confirmation dialog.

The Rails team strongly encourages you to write your JavaScript in this style, 
and you can expect that many libraries will also
follow this pattern.


Using ES6 in Rails
----------

Rails comes with CoffeeScript as a default. It is transpiled to JavaScript
by the asset pipeline. To disable this just comment out the gem in the Gemfile
and remove any *.coffee files the scaffold might have created from `/app/assets/javascript`

To use Ecmascript 6 instead add the following to the Gemfile:

```
gem 'sprockets'
gem 'sprockets-es6', require: 'sprockets/es6'
```

Now any file `/app/assets/javascript/hello_world.js.es6` will be
transpiled to `/app/assets/javascript/hello_world.js` first, and
later be minified and combined by the asset pipeline.

For example:

```
class HelloWorld {  
  constructor(name) {
    this.name = name;
  }
 
  sayHello() {
    alert("Hello " + this.name);
  }
}
```

```
<button data-hello="world">Hello World</button>
```

Can now can write the ES6 / JavaScript to call this unobstrusively!


Turbolinks
----------

Rails ships with the [Turbolinks gem](https://github.com/rails/turbolinks).
This gem uses Ajax to speed up page rendering in most applications.

### How Turbolinks Works

Turbolinks attaches a click handler to all `<a>` on the page. If your browser
supports
[PushState](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history#The_pushState%28%29_method),
Turbolinks will make an Ajax request for the page, parse the response, and
replace the entire `<body>` of the page with the `<body>` of the response. It
will then use PushState to change the URL to the correct one, preserving
refresh semantics and giving you pretty URLs.

Turbolinks are enabeld by default in new rails applications.

For older applications add Turbolinks to the Gemfile,
and put `//= require turbolinks` in your JavasScript manifest
`app/assets/javascripts/application.js`.

If you want to disable Turbolinks for certain links, add a `data-no-turbolink`
attribute to the tag:

```html
<a href="..." data-no-turbolink>No turbolinks here</a>.
```

### Page Change Events

When writing JavaScript, you'll often want to do some sort of processing upon
page load. With jQuery, you'd write something like this:

```js
$(document).ready(function(){
  alert("page has loaded!");
});
```

However, because Turbolinks overrides the normal page loading process, the
event that this relies on will not be fired. If you have code that looks like
this, you must change your code to do this instead:

```js
$(document).on("page:change", function(){
  alert("page has loaded!");
});
```

For more details, including other events you can bind to, check out [the
Turbolinks
README](https://github.com/rails/turbolinks/blob/master/README.md).

Built-in Helpers 
----------------------

Rails provides a bunch of view helper methods written in Ruby to assist you
in generating HTML. Sometimes, you want to add a little Ajax to those elements,
and Rails has got your back in those cases.

Because of Unobtrusive JavaScript, the Rails "Ajax helpers" are actually in two
parts: the JavaScript half and the Ruby half.

[rails.js](https://github.com/rails/jquery-ujs/blob/master/src/rails.js)
provides the JavaScript half, and the regular Ruby view helpers add appropriate
tags to your DOM. The JavaScript in rails.js then listens for these
attributes, and attaches appropriate handlers.

### form_for

[`form_for`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_for)
is a helper that assists with writing forms. `form_for` takes a `:remote`
option. It works like this:

```erb
<%= form_for(@article, remote: true) do |f| %>
  ...
<% end %>
```

This will generate the following HTML:

```html
<form accept-charset="UTF-8" action="/articles" class="new_article" data-remote="true" id="new_article" method="post">
  ...
</form>
```

Note the `data-remote="true"`. Now, the form will be submitted by Ajax rather
than by the browser's normal submit mechanism.

You probably don't want to just sit there with a filled out `<form>`, though.
You probably want to do something upon a successful submission. To do that,
bind to the `ajax:success` event. On failure, use `ajax:error`. Check it out:

```js
  $(document).on("page:change", function(){
    $("#new_article").on("ajax:success", function(e, data, status, xhr) {
      $("#new_article").append(xhr.responseText);
    }).on("ajax:error", function(e, xhr, status, error) {
      $("#new_article").append("<p>ERROR</p>");
    });
  });
```

Obviously, you'll want to be a bit more sophisticated than that, but it's a
start. You can see more about the events [in the jquery-ujs wiki](https://github.com/rails/jquery-ujs/wiki/ajax).

### form_tag

[`form_tag`](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag)
is very similar to `form_for`. It has a `:remote` option that you can use like
this:

```erb
<%= form_tag('/articles', remote: true) do %>
  ...
<% end %>
```

This will generate the following HTML:

```html
<form accept-charset="UTF-8" action="/articles" data-remote="true" method="post">
  ...
</form>
```

Everything else is the same as `form_for`. See its documentation for full
details.

### link_to

[`link_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)
is a helper that assists with generating links. It has a `:remote` option you
can use like this:

```erb
<%= link_to "an article", @article, remote: true %>
```

which generates

```html
<a href="/articles/1" data-remote="true">an article</a>
```

You can bind to the same Ajax events as `form_for`. Here's an example. Let's
assume that we have a list of articles that can be deleted with just one
click. We would generate some HTML like this:

```erb
<%= link_to "Delete article", @article, remote: true, method: :delete %>
```

and write some JavaScript like this:

```js
$("a[data-remote]").on("ajax:success", function(e, data, status, xhr) {
  alert("The article was deleted.");
});
```

### button_to

[`button_to`](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to) is a helper that helps you create buttons. It has a `:remote` option that you can call like this:

```erb
<%= button_to "An article", @article, remote: true %>
```

this generates

```html
<form action="/articles/1" class="button_to" data-remote="true" method="post">
  <input type="submit" value="An article" />
</form>
```

Since it's just a `<form>`, all of the information on `form_for` also applies.

Server-Side Concerns
--------------------

Ajax isn't just client-side, you also need to do some work on the server
side to support it. Often, people like their Ajax requests to return JSON
rather than HTML. Let's discuss what it takes to make that happen.

### The Recipe / Ingredients Example

You can clone the source code for the example from
[github](https://github.com/backend-development/rails-example-recipes-js)

On the List of Ingredients page we want the 'edit' links to 
load an inline form for editing the ingredient.

![](images/inline_form_2.png)

As a first step we change the `link_to` to `remote`:

```
link_to 'Edit', edit_ingredient_path(ingredient), remote: true
```

Now clicking the link fails silently.  In the log file you can
see that the edit-view is rendered normally.  But we need
a different behaviour in case this view is called from JavaScript.
We also want to keep the normal behaviour as it is.

In a rails controller you can use `resond_to` to handle
different expected results:  in our case the browser once 
expects HTML as the result when doing a normal GET Request,
while the Rails `link_to :remote` link expects javascript
as a result:

```
respond_to do |format|
  format.html { render :new }
  format.js   { render 'new.js.erb' }
end
```

The link still fails silently. We can handle
the AJAX error like so:

```  
$(".edit_ingredient").on("ajax:error", function(e, xhr, status, error) {
  $(this).parent().append("<b>AJAX ERROR " + status + ": " + error + "</b>");
});
```

Now we implement the `new.js.erb` view.  The Javascript
created here is sent back to the client and executed
there.  Try it out with a simple alert:

```
alert("this was sent back from the server, for ingredient  <%= @ingredient.id %>");
```

If this works we can start building the 
behaviour we actually want:  We want to replace
the existing display of the ingredient with the
edit form.

```
console.log("now running for <%= @ingredient.id %>");
$("#ingredient_<%= @ingredient.id %>").find('span').html('edit form here');
```

For the creation of the form we can use the existing form partial
in place of the string. We need to escape the resulting code
in the proper way for using it in javascript:

```
....html('<%= escape_javascript(render 'form') %>');
```

As a more advanced exercise you could also make the "update" button of the form 
work with AJAX.

### Another Example

Imagine you have a series of users that you would like to display and provide a
form on that same page to create a new user. The index action of your
controller looks like this:

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    @user = User.new
  end
  # ...
```

The index view (`app/views/users/index.html.erb`) contains:

```erb
<b>Users</b>

<ul id="users">
<%= render @users %>
</ul>

<br>

<%= form_for(@user, remote: true) do |f| %>
  <%= f.label :name %><br>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
```

The `app/views/users/_user.html.erb` partial contains the following:

```erb
<li><%= user.name %></li>
```

The top portion of the index page displays the users. The bottom portion
provides a form to create a new user.

The bottom form will call the `create` action on the `UsersController`. Because
the form's remote option is set to true, the request will be posted to the
`UsersController` as an Ajax request, looking for JavaScript. In order to
serve that request, the `create` action of your controller would look like
this:

```ruby
  # app/controllers/users_controller.rb
  # ......
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.js   {}
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
```

Notice the format.js in the `respond_to` block; that allows the controller to
respond to your Ajax request. You then have a corresponding
`app/views/users/create.js.erb` view file that generates the actual JavaScript
code that will be sent and executed on the client side.

```erb
$("<%= escape_javascript(render @user) %>").appendTo("#users");
```

Other Resources
---------------

Here are some helpful links to help you learn even more:

* [Original Rails Guide Working with JavaScript](http://guides.rubyonrails.org/working_with_javascript_in_rails.html).
* [jquery-ujs wiki](https://github.com/rails/jquery-ujs/wiki)
* [Events created by Rails AJAX](https://github.com/rails/jquery-ujs/wiki/ajax)
* [Using ES6 in Rails article](http://www.kwanso.com/blog/using-ecmascript-6-with-rails-4-2-projects/)
* [Railscasts: Unobtrusive JavaScript](http://railscasts.com/episodes/205-unobtrusive-javascript)
* [Railscasts: Turbolinks](http://railscasts.com/episodes/390-turbolinks)
