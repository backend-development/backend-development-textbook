Scaling Node 
=========================


After working through this guide you should be able to

* set up cluster.js to run several node instances


-------------------------------------------------------------

Node and the Command Line
------

## Arguments

The array `process.argv` contains information about how the program
was started:

```
node fs.js file.txt
```

The contents of the array might be:

```
['/Users/b/.nvm/versions/node/v5.9.0/bin/node',  '/Users/b/code/fs.js', 'file.txt' ]
```


## Standard Input and Standard Output channels

are streams in node:

```javascript
process.stdout.write("Hello World\n"); 
process.stderr.write("you're doing it wrong");
console.log("this", true, 42, that);
```


```shell
node app.js > out.txt 2> err.txt
```

## environment variables

## process id

```javascript
console.log(`process ${process.pid}`)
```

Or find it on the commandline:

``` shell
$ ps
  PID TTY           TIME CMD
71422 ttys000    0:00.05 bash
20877 ttys002    0:00.11 node app.js
```


## Sending and reacting to signals

```javascript
process.on( "SIGINT", function() {
  console.log(`stopping`);
  process.exit();
});
```

Send SIGINT by pressing CTRL-C
Send SIGINT with `kill 20877`


SIGTERM is used by docker, always handle it!

```
process.on( "SIGTERM", function() {
  console.log(`stopping`);
  process.exit();
});
```

SIGHUB can be used for less serious signals, for example
to get the app to dump some statistics, or reload a configuration file:

```
let count = 1;
process.on( "SIGHUP", function() {
  console.log(`count = ${count}`);
});
```

```
kill –HUP 20877
```

Scaling Node with cluster.js
--------

V8 has a default memory limit of ~1.5GB
If your server has more memory
this might be unsatisfactory! 
You can increase this by starting node with the option
`--max-old-space-size`.


The Eventloop uses 1 core
If your server has 64 cores 
this might be unsatisfactory!
To get around this limitation use cluster.js

```
const cluster = require('cluster');
const http = require('http');
const numCPUs = require('os').cpus().length;
if (cluster.isMaster) {
  for (var i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
} else {
  console.log('working!');
}
```


sockets are shared between slave processes:

```
if (cluster.isMaster) {
  // ...
} else {
  // Workers can share any 
  // TCP connections
  http.createServer((req, res) => {
    res.writeHead(200);
    res.end('hello world\n');
  }).listen(8000);             
}
```


the master process is in charge:

```
if (cluster.isMaster) {
  for (var i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
  cluster.on('exit', (worker, code, signal) => {
    console.log(`${worker.process.pid} died`);
  });
}
```


they do not share the same memory space
= objects are local to each instance of the app.
You cannot maintain state in the application code!
You can send messages:


```
const cluster = require('cluster');
const http = require('http');
const numCPUs = require('os').cpus().length;
if (cluster.isMaster) {
  for (var i = 0; i < numCPUs; i++) {
    let worker = cluster.fork();
    worker.send('do something!'); 
  }
} else {
 process.on('message', (msg) => { 
   process.send('nope.'); 
 }); 
}

```

Where do we keep the state of the app? The answers
are the same as for PHP, Rails, etc:

* in a Database (full featured)
* in a key value store like Memcached, Redis (faster, minimal features)
* by sending messages





See Also
-------


* [cluster.js documentation](https://nodejs.org/api/cluster.html)
* [pm2 - process manager for Node.js](http://pm2.keymetrics.io/)



