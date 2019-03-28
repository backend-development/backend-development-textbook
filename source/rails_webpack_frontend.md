# Building the Frontend with Webpack

While the asset pipeline is rails' way of preparing
files for the frontend, in recent years a completely
different toolchain was developed in the frontend community.

In this guide you will learn how to integrate webpack
and a current frontend framework with your rails app.
You will be able to:

*   Use React with Ruby on Rails

REPO: Fork the [example app 'xxx'](https://github.com/backend-development/xxx) and try out what you learn here.

---

## Frontend Pipelines

When the rails asset pipeline was published with Rails 3.1 in 2011, node.js
was only 2 years old and version 1.0 of npm was just released.  
In the years since, the frontend community developed, released (and dropped) a lot of
new tools: bower, grunt, gulp, yarn, webpack.

Since Rails 5.1 the webpacker gem is officialy part of Rails. It integrates webpack
into rails, and makes developing with react, vue, angular or other frontend frameworks
easy.

Webpacker coexists with the asset pipeline.  You can start using webpacker for
certain aspects of your Rails app, for example just one page with very complex, UI,
and still continue using the asset pipeline for the rest. 


## Files

Webpacker creates a new folder `app/javascript` and a folder structure:

![](images/javascript-folder.png)

## To be Continued

## Further Reading

