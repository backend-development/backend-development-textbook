Node.js vs Rails
=========================

After working through this guide you should

* understand the differences and similarities of JS and Ruby
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
curly braces and semicolons. But it add's it's own idiosyncrasies 
(e.g. you can leave out the semicolons).


```
// Javascript
if (this) {    
  console.log('Hello World');
}
```

Ruby mostly uses words instead of curly braces, and no Semicolons

```
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

```
irb> "3" + 5
TypeError: no implicit conversion of Fixnum into String
irb> "3".to_i + 5
8
```

Javascript converts types automatically.

```
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
In JavaScript you will uses **anonymous functions** a lot, for example for handling events as in the next example, but also in other contexts:

```
$(document).ready(function(){
  $('button').click(function(){
    /* amazing things */
  });
});
```

But let's look at an example that is better for comparing with Ruby:
In Ruby you will use **blocks**:


```
a.map{|x| x* 2}.each do |x|
  puts "#{x} is not a prime"
end
```

This example shows a one-line-block in the curly braces and a big block 
delimited by `do`, `end`. In JavasScript (2015) you can write very simliar code. 
Here the fat arrow-notation for anonymous functions is used:

```
a  
  .map(x => x * 2)  
  .forEach(x => {    
    console.log(`${x} is not a prime`)  
  });
```


Node vs Rails: 
-----------------------

### apples vs. oranges

Comparing node to rails is not quite a fair comparison:

Rails is a complete framework for a web backend, with ORM, Templates, 
Asset Pipeline and many more features already decided and set up for you.

Node is one building block for a web backend. You need to pick a ORM, 
a templating system, a way you want to set up the frontend asset pipeline, 
and assemble all of these pieces to build you web app.

It would be more appropriate to compare Rails to Sails (a complete node 
backend framework) or to compare express (a minimal node backend) to Sinatra 
(a minimal ruby backend).


### processing model for plain HTTP / REST

Ruby on Rails follows the classical model of backend languages 
that goes back to the stateless nature of HTTP: As a developer 
you get to treat each HTTP request separately. 
Your mental model of the program might be:

1. a request comes in
2. the framework hands me the session and the parameters
3. my program runs
4. it can store some things to the database or session that need to stick around for the next request
5. then it writes out the resulting html (or JSON, or whatever)
6. and then my program ends, clearing all variables, freeing all memory

With Node you not only write a backend program, you also write the 
web server. The variables you handle are shared between all HTTP 
requests. Your mental model needs a lot more complex:

1. my node app is started
2. it needs to load configuration, establish database connections, organize them in a pool, prepare some global variables
3. then I spin up a web server that handles HTTP requests.
4. for each request
    1. the middleware hands me the request,
    2. i can store some things in the database, or in global variables, to stick around for the next request
    3. then I return the resulting html (or JSON, or whatever)
5. I might want to react to signals to re-read configuration or initiate some clean up before shutdown


### asyn vs sync

Node relies heavily on asynchronous processing. As a programmer 
you have to write asynchronous code for common actions like:

* sending a request to a database + handling the results
* reading from a file + handling the data that has been read

```
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
actions in JavaScript. 

For many years 
[error first callbacks](http://fredkschott.com/post/2014/03/understanding-error-first-callbacks-in-node-js/)
were the preferred style in node. Right now Promises seem to 
be the future favorite solution. But the discussion is still open
and there tons of apps out there written in other styles.

Error handling and asynchronicity is a hard problem, 
see the [node documentation on error handling](https://www.joyent.com/developers/node/design/errors) 
to get an impression of the complexity involved.

In Rails you access files and databases in a synchronous fashion. 
Only actions that would take longer than the user 
is willing to wait for a response are handled by "workers":

```
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

Ruby and JavaScript a similar programming languages.

node.js and Rails represent two very different approaches for programming a web backend. 
As a developer, nodes.js will confront you with harder problems to solve, 
while Rails will try to solve the hard problems for you 
and give you a simple programming model to work with.

For beginners I would recommend Ruby and Rails in the backend and 
JavaScript with jQuery in the frontend. For more advanced programmers 
I would recommend getting to know node.js, and deciding between node.js 
and Rails on a case by case basis.

This text was first published as [an answer on quora](https://www.quora.com/Is-Ruby-on-Rails-easier-to-learn-than-Node).
