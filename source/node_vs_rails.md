Node.js vs Rails
=========================

After working through this guide you should

* understand the differences and similarities of JavaScript and Ruby
* understand the different roles node.js and Rails have

-------------------------------------------------------------

JavaScript vs. Ruby
-------------

### Background

Both JavaScript and Ruby are interpreted languages with more than
20 years of history. The both were influenced by object orientation
and functional programming.


### Syntax

JavaScript Syntax is inspired by the C family of languages:
curly braces and semicolons. But it adds it's own idiosyncrasies
(e.g. you can leave out the semicolons).


```js
// Javascript
if (this) {
  console.log('Hello World');
}
```

Ruby mostly uses words instead of curly braces, and no Semicolons

```ruby
# Ruby
if this
  puts 'Hello World'
end
```

### Variables and Types

Both Interpreter will check if your variables were initialized before
you start using them. In both languages values are typed,
but variables are not: you can store values of different type in the same variable:

```
a = 5
a = "not a problem"
a = 3.141
```

Ruby is strongly typed:

```ruby
irb> "3" + 5
TypeError: no implicit conversion of Fixnum into String
irb> "3".to_i + 5
8
```

Javascript converts types automatically.

```js
js> "3" * 5
15
js> "3" + 5   // string concatenation!
"35"
js> 3 + 5   // addition!
8
```


The plus sign is both used for mathematics and for string concatenation in JavaScript.


### functions vs blocks

Both languages have their ways of organizing the code that is found rarely in other languages:
In JavaScript you will uses **arrow functions**  a lot.
Here we use them for handling events:

```js
window.addEventListener('DOMContentLoaded', () => {
  document.getElementById('buttonId').addEventListener("click", () => {
    console.log('button clicked');
  });
});
```

But let's look at an example that is better for comparing with Ruby:
In Ruby you will use **blocks**:


```ruby
a.map{|x| x * 2}.each do |x|
  puts "#{x} is not a prime"
end
```

This example shows a one-line-block in the curly braces and a big block
delimited by `do`, `end`. In JavasScript you can write very simliar code.
Here the fat arrow-notation for anonymous functions is used:

```js
a.map(x => x * 2).forEach(x => {
  console.log(`${x} is not a prime`)
});
```


Node vs Rails:
-----------------------

### apples vs. oranges

Comparing Node to Rails is not quite a fair comparison:

Rails is a complete web backend framework, with ORM, templates,
testing setup and a lot of other features that are already decided and set up for you.

Node is a building block for a web backend. If you want an ORM, you can pick one.
There are three templating systems to choose from. If you need testing, you have to set it up yourself.
And you have to put all these pieces together to build your web application.

It would be more appropriate to compare Rails to nest.js (a complete node
backend framework), or Express (a minimal Node.js backend) to Sinatra
(a minimal Ruby backend).


### processing model for plain HTTP / REST

Following the classic model of backend languages, Ruby on Rails
takes advantage of the stateless nature of HTTP: as a developer, you can
developer, you can treat each HTTP request separately.
Your mental model of the program might be

1. a request comes in
2. the framework gives me the session and parameters
3. my program runs
4. it may store some things in the database or in the session
5. then it writes out the resulting HTML (or JSON, or whatever)
6. and then my program exits, clearing all variables and freeing all memory.

With Node, you not only write a backend program, you also write the
web server. The variables you manipulate are shared between all HTTP
requests. Your mental model needs to be much more complex:

1. my Node application starts
2. it needs to load configuration, make database connections, organise them in a pool, prepare some global variables
3. then I spin up a web server that handles HTTP requests
4. for each request
    1. the middleware gives me the request
    2. I can store some things in the database or in global variables to hold for the next request
    3. then I return the resulting HTML (or JSON, or whatever)
5. I might want to respond to signals to re-read the configuration, or do some cleanup before shutdown.
This goes back to the stateless nature of HTTP: as a developer
you can treat each HTTP request separately.
Your mental model of the program might be

1. a request comes in
2. the framework gives me the session and parameters
3. my program runs
4. it may store some things in the database or in the session
5. then it writes out the resulting HTML (or JSON, or whatever)
6. and then my program exits, clearing all variables and freeing all memory.


### asyn vs sync

Node relies heavily on asynchronous processing. As a programmer
you have to write asynchronous code for common actions like:

* sending a request to a database + handling the results
* reading from a file + handling the data that has been read

```js
db.get('users', userId, function(err, user) {
  if(!err) {
    fs.readFile(user.profilepic, function(err,data){
      if(!err) {
        // create thumbnail from profile pic
      }
    });
});
```

There are several different programming styles to handle asynchronicity,
chaining asynchronous actions, and handling errors from asynchronous
actions in JavaScript. For many years
[error first callbacks](https://fredkschott.com/post/2014/03/understanding-error-first-callbacks-in-node-js/)
were the preferred style in node. sind 2015  Promises are supported natively, and since
2014 async await is fully supported.



In Rails you access files and databases in a synchronous fashion.
Only actions that would take longer than the user
is willing to wait for a response are handled by "workers":

```ruby
class ThumbnailJob < ActiveJob::Base
 queue_as :default

 def perform(user)
   img = Magick::Image.read(user.profilepic).first
   # create a thumbnail
 end
end

# in a controller somewhere:
ThumbnailJob.perform_later current_user
```


Summary
---------

Ruby and JavaScript are similar programming languages.

node.js and Rails represent two very different approaches for programming a web backend.
As a developer, nodes.js will confront you with harder problems to solve,
while Rails will try to solve the hard problems for you
and give you a simple programming model to work with.

For beginners I would recommend Ruby and Rails in the backend and
plain JavaScript  in the frontend.

This text was first published as [an answer on quora in 2016](https://www.quora.com/Is-Ruby-on-Rails-easier-to-learn-than-Node).
The version on this website was
 updated in 2023.
