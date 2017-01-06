JavaScript and AJAX in Rails
================================

This guide covers the built-in Ajax/JavaScript functionality of Rails; 
it will enable you to create rich and dynamic Ajax applications with
ease!

After reading this guide, you will know:

* unobtrusive JavaScript,
* how to use ES6 in your Rails app,
* the basics of Ajax,
* how Rails handles Ajax,
* how built-in helpers assist you,
* the Turbolinks gem.

This guide is based on the original
[Rails Guide Working with JavaScript](http://guides.rubyonrails.org/working_with_javascript_in_rails.html).
The original guide uses coffeescript, this guide uses ES6 and
refers to an [example app](https://github.com/backend-development/rails-example-recipes-js)

REPO: Fork the [example app 'recipes'](https://github.com/backend-development/rails-example-recipes-js) and try out what you learn here.

-------------------------------------------------------------------------------

Unobtrusive JavaScript
-------------------------------------

Rails uses a technique called "Unobtrusive JavaScript" to handle attaching
JavaScript to the DOM.  The goal is to separate javascript from html as
much as possible. So instead of writing inline JavaScript:

```html
<a href="#" onclick="this.style.backgroundColor='#990000'">Paint it red</a>
```
We extract the code into a JavaScript funktion, and only attach the event
handler to the a-tag after the page has loaded. To encourage reuse of JavaScript
funktions we try to add all the data needed in html data-attributes:

Not very DRY, eh? We can fix this by using events instead. We'll add a `data-*`
attribute to our link, and then bind a handler to the click event of every link
that has that attribute:

```js
  $(function(){
    $("a[data-background-color]").click(function(e) {
      e.preventDefault();
      var backgroundColor = $(this).data("background-color") || this.style.backgroundColor;
      var textColor       = $(this).data("text-color")       || this.style.color; 
      this.style.backgroundColor = backgroundColor;
      this.style.color = textColor;
    });
  });
```
```html
<a href="#" data-background-color="#990000">Paint it red</a>
<a href="#" data-background-color="#009900" data-text-color="#FFFFFF">Paint it green</a>
<a href="#" data-background-color="#000099" data-text-color="#FFFFFF">Paint it blue</a>
```

This is called 'unobtrusive' JavaScript because we're no longer mixing 
JavaScript into the HTML. We've properly separated our concerns, making future
change easy. 

Take a look at the standard "destroy" links created by the scaffold:
they use `data-confirm` to unobstrusively add a confirmation dialog.

The Rails team strongly encourages you to write your JavaScript in this style, 
and you can expect that many libraries will also
follow this pattern.


Using ES6 in Rails
----------

Rails comes with CoffeeScript by default. It is transpiled to JavaScript
by the asset pipeline. CoffeeScript gives you a simpler, more ruby-like syntax,
including arrow functions and a secure for in loop. This was very valuable
three or five years ago.  But in 2017 ES6 also gives you arrow functions
and a for of loop, so you might not need CoffeeScript after all.

To disable CoffeeScript just comment out the gem in the Gemfile
and remove any *.coffee files the scaffold might have created from `/app/assets/javascript`

To use ES6 instead follow the instructions for 
the [sprockets-es6 gem](https://github.com/TannerRogalsky/sprockets-es6).
With this gem
any file in `/app/assets/javascript/` with extension `.js.es6` will be
transpiled to JavaScript first, and later be minified and combined by the asset pipeline.
You do not need to write modules or import them, because all the JavaScript
code will be combined into one file.

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
powers, you can write JavaScript that updates just parts of a webpage,
without needing to get the full page from the server. This is a
powerful technique called [Ajax](https://en.wikipedia.org/wiki/Ajax_(programming)).

Rails provides quite a bit of built-in support for building web pages with this
technique. 

Ajax and Rails
--------------------

Ajax isn't just client-side, you also need to do some work on the server
side to support it. Often, people like their Ajax requests to return JSON
rather than HTML. In Rails a different style of programming is supported:
The Server returns JavaScript code to the client.  

### The Recipe / Ingredients Example

You can clone the source code for the example from
[github](https://github.com/backend-development/rails-example-recipes-js)

Let's have a look at the list of ingredients, and how an ingredient
can be edited with the normal CRUD operations created by the scaffold.
There are four HTTP requests and three full page loads in this process:

![](images/rails-js-1.jpg)

We want to replace this with a version that uses Rails typical AJAX. When
the 'edit' link is clicked the server returns JavaScript that places
the form into the existing page.
When the form is submitted - also via AJAX - the server returns
JavaScript that enters the name of the new ingredient into 
the existing list.

This still needs four HTTP requests, but a lot less data is transferred
and - more importantly - there is no new full  HTML page for the browser
to parse and display.  The URLs stay almost the same: 

![](images/rails-js-2.jpg)

As a first step we change the `link_to` to `remote`:

```
link_to 'Edit', edit_ingredient_path(ingredient), remote: true, class: 'edit_ingredient'
```

Now clicking the link fails silently.  In your
browsers network view you can
see that a GET request is sent, and HTML code
is returned (just like before):

![](images/rails-js-network-html.png) 

But our Ajax request does not handle the HTML.
In fact, our Ajax requests expects the response to
contain JavaScript code!  If you look in the Rails log
you can see that:

![](images/rails-js-log.png) 

Rails is already prepared to respond to both requests
that expect HTML and those that expect JavaScript.
In fact we only have to create a view `new.js.erb`
and Rails will render that.

Try it out with a simple alert:

```
alert("from the server, for ingredient  <%= @ingredient.id %>");
```

The result should be an alert in your browser:

![](images/rails-js-alert.png) 

If this works we can start building the 
behaviour we actually want:  We want to replace
the existing display of the ingredient with the
edit form. Let's find a good place in the
DOM to do that:

![](images/rails-js-dom.png) 

The paragraph has an id that identifies the ingredient.
That is a good place to start.  Then we find the first
span inside that and replace the existing content:

```
console.log("now running for <%= @ingredient.id %>");
$("#ingredient_<%= @ingredient.id %> span").html('put the form here!');
```

For the creation of the form we can use the existing form partial. 
We need to escape the resulting code
in the proper way for using it in javascript:

```
....html('<%= escape_javascript(render 'form') %>');
```

There is a short version for `escape_javascript`: just the letter `j`.
And we can leave the braces off:

```
....html('<%= j render 'form' %>');
```

At this stage the app is fully functional again: If you send
in the form via normal PATCH request a new page is rendered,
and everything works.

But we will not stop here. We will turn this form into a "remote form".
We can do this by adding the `data-` attribute to it.
The form has a unique id we can use to identify it:

```
$("#edit_ingredient_<%= @ingredient.id %>").data('remote', true);
```

The form sends a PATCH request via Ajax, which will be handled
by the `update` action.  This action already specifies
two formats it can handle: html and json:

```
# PATCH/PUT /ingredients/1
# PATCH/PUT /ingredients/1.json
def update
  respond_to do |format|
    if @ingredient.update(ingredient_params)
      format.html { redirect_to ingredients_path, notice: 'Ingredient was successfully updated.' }
      format.json { render :show, status: :ok, location: @ingredient }
    else
      format.html { render :edit }
      format.json { render json: @ingredient.errors, status: :unprocessable_entity }
    end
  end
end
```

This limits the allowed format, we have to add `.js` explicitly:
```
# PATCH/PUT /ingredients/1
# PATCH/PUT /ingredients/1.json
# PATCH/PUT /ingredients/1.js
def update
  respond_to do |format|
    if @ingredient.update(ingredient_params)
      format.html { redirect_to ingredients_path, notice: 'Ingredient was successfully updated.' }
      format.json { render :show, status: :ok, location: @ingredient }
      format.js { }
    else
      format.html { render :edit }
      format.json { render json: @ingredient.errors, status: :unprocessable_entity }
      format.js { }
    end
  end
end
```

Now we have to handle both cases: saving `@ingredient` caused errors or went through
successfully.  There is a length validation on the ingredient name,
so typing in just one letter should cause an error. Try it out with this code:

```
<% if @ingredient.errors.any? %>
alert("error: <%= @ingredient.errors.full_messages.first %>");
<% else %>
alert("saved successfully");
<% end %>
```

In case of success we want to remove the form and replace it with
the new name of the ingredient.  This is left as an exercise for the reader.


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


Other Resources
---------------

Here are some helpful links to help you learn even more:

* [Original Rails Guide Working with JavaScript](http://guides.rubyonrails.org/working_with_javascript_in_rails.html).
* [jquery-ujs wiki](https://github.com/rails/jquery-ujs/wiki)
* [Events created by Rails AJAX](https://github.com/rails/jquery-ujs/wiki/ajax)
* [Using ES6 in Rails article](http://www.kwanso.com/blog/using-ecmascript-6-with-rails-4-2-projects/)
* [Railscasts: Unobtrusive JavaScript](http://railscasts.com/episodes/205-unobtrusive-javascript)
* [Railscasts: Turbolinks](http://railscasts.com/episodes/390-turbolinks)
