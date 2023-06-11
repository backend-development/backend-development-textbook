Node Web App
=========================


After working through this guide you should be able to

* set up and program a web project with express
* understand the role of connect middleware
* build a REST API with node.js

-------------------------------------------------------------


We have already seen a very basic web server in node.js:

```
import * as http from 'http';

const hostname = '127.0.0.1';
const port = 3000;

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello Web\n');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});
```

Not let's look at connect and express, two libraries
that make web projects easier.


Connect
-----

Connect is a middleware framework for node
Built on top of node’s Http Server

```
var connect = require('connect');
var app = connect()
  .use(function(req, res){
    res.end('hello world\n');
  })
  .listen(3000);
console.log("server listening on port 3000");
```

![](images/connect.svg)


## Write you own middleware

Write a function that recieves the arguments
request, response and next.  This function can
read from and also manipulate request and response.
After it is done, it must call `next()` to hand
over control to the next middleware.

```
var connect = require('connect');

var app = connect()
    // my middleware
    .use(function(request, response, next) {
        console.log(`Request for ${request.url} with method ${request.method}`);
        next();
    })
    // handle all requests
    .use(function onRequest(request, response) {
        response.end('Hello from connect with middleware!');
    })
    .listen(3000);
console.log("Server listening on port 3000");
```

## Express

Express is a minimalist framework for building
APIs and server rendered web apps with node.js.
It offers:


* a project generator
* request / response enhancements
* routing
* view support
* HTML helpers
* content negotiation


it is built on top of `connect`.



### Setup


```
npx express-generator --git projectname
```

Creates your project with all the necessary packages.

```
cd projectname
npm install
```


Installs all dependencies to your project

```
DEBUG=node-express:* npm start
```

has your project up and running


## Building an API

If you want to use express for an API only, you can
set it up without views:

```
npx express-generator --no-view --git restproject
```

### Serving static assets

The generator  created a folder public/ with some files
and subfolders:

```
   create : restproject/
   create : restproject/public/
   create : restproject/public/javascripts/
   create : restproject/public/images/
   create : restproject/public/stylesheets/
   create : restproject/public/stylesheets/style.css
   create : restproject/public/index.html
```

the `express.static` middleware is used to
serve these files. It will look for  `index.html` if
a folder is requested.


```javascript
app.use(express.static(path.join(__dirname, 'public')));
```

### Routes

In more complex MVC (Model-View-Controller) frameworks, controllers and routing are treated as separate entities.
However, in Express.js, both of these tasks are managed by routes.

It's common practice to divide routing into multiple files.

```javascript
// in file app.js
var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');

app.use('/', indexRouter);
app.use('/users', usersRouter);
```


```javascript
// in ./routes/users.js
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('respond with a resource');
});

module.exports = router;
```

The routes in file users.js are relative to the
base-route set in app.js.

### Serving JSON

The express.json middleware will convert
a javascript data structure into JSON and
serve it with the appropriate content type:


```javascript
// in file app.js
app.use(express.json());

// in ./routes/users.js
var users = [
  { name: 'konsti' }
  , { name: 'johannes' }
  , { name: 'lara' }
  , { name: 'tanja' }
];

router.get('/', function(req, res, next) {
  res.send(users);
});

// result in browser:
[{"id":1,"name":"konsti"},{"id":2,"name":"johannes"},{"id":3,"name":"lara"},{"id":4,"name":"tanja"}]
```


### More Routing

URLs can contain parameters in two ways: as query parameters:

http://localhost:3000/users?name=Jin


```javascript
// in ./routes/users.js
app.get('/', (req, res) => {
    let name = req.query.name;  // Jin
    // ...
});
```

Sometimes we want to identify parts of the URL:

http://localhost:3000/users/3

Here we can use express route parameters:

```javascript
// in ./routes/users.js
/* GET one users  - use :id in the path, and read req.params.id */
router.get('/:id', function(req, res, next) {
  var user = users.find( u => u.id == req.params.id)
  res.send(user);
});
```

Use the http methods as function names, or use `all` to catch
all methods:


```javascript
// in ./routes/users.js
/* POST one users  - use :id in the path, and read req.params.id */
router.post('/:id', function(req, res, next) {
  var user = users.find( u => u.id == req.params.id)
  res.send(user);
});
```

### Set up CORS for a frontend




## Server rendered HTML

express supports several different templating engines.


### Views with JADE

```
app.get('/', function (req, res) {
    res.render('index', {user: 'Welt'});
});
```


```
extends layout

block content
    h1 Hallo #{user}
    a(href='https://google.com') Google
    ul
      - for (var x = 0; x < 3; x++)
        li bla
```


### Working with data


Pass data to the views

```
res.render('index', { title: 'Customer List' });
```


Read data from form

```
app.use(bodyParser.urlencoded({ extended: false }));
app.post('/', function(req, res){
  var userName = req.body.username;
  res.send(`Hello ${username}<br><a href="/">Try again.</a>`);
});
```


Read and send files

```
let filePath = req.files.picture.path;
res.sendfile(filePath); // also: sets Content-Type from ext
// res.download(filePath);  // same, as attachment, size
```


Data for all views

```
app.locals.clock = new Date().toUTCString();
```

clock is now available in all views:

```
p This Server started at #{clock}
```




See Also
-------


* [frameworks recommended by express](https://expressjs.com/en/resources/frameworks.html)



