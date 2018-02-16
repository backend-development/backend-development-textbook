Building the Frontend with Webpack
===================

While the asset pipeline is rails' way of preparing
files for the frontend, in recent years a completely
different toolchain was developed in the frontend community.

In this guide you will learn how to integrate webpacker
and a current frontend framework with your rails app.
You will be able to:

* 
* 

REPO: Fork the [example app 'xxx'](https://github.com/backend-development/xxx) and try out what you learn here.


---------------------------------------------------------------------------

Frontend Pipelines
----------------


When the rails asset pipeline was published with rails 3.1 in 2011, node.js
was only 2 years old. Versio 1.0 of npm, the node package manager, was released at the
same time as the asset pipeline.

In the years since, the frontend community developed, released (and dropped) many
new tools: bower, grunt, gulp, yarn, webpacker.

With Rails 5.1 webpacker is now an official part of rails. It  coexists with the asset pipeline.
The primary purpose for webpack is app-like JavaScript,
not images, CSS, or even small JavaScript "sprinkles" to use in server generated html.



Files
------


![](images/javascript-folder.png)




Further Reading
--------------


