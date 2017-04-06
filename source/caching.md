Caching
=======================

What is even better than having a really fast web
server, framework, programming language that creates
your web page?  Not having to create and load the page at all
becaus it's already there in a cache.

After working through this guide you will:

* be aware of many levels of caches that influence your web app
* be able to configure rails for caching


REPO: You can study [the demo](https://shrouded-dawn-29154.herokuapp.com/) for the example described here.

---------------------------------------------------------------------------


Performance
-----------

Before you start "optimizing" the performance of your web application 
you should consider these wise words:

"We should forget about small efficiencies, say about 97% of the time: premature optimization is the root of all evil" -- Donald Knuth

This is a warning against making things worst by trying to "optimize" them.
It's not an "optimization" if you make things worst. So keep these things
in the right order:


1. Is there a performance problem? If not: stop. do not change your system. It is good enough.
2. Find out where the bottleneck is. Do this by measuring, using appropriate tools.
3. If you found the right place, only then you can start to "optimize"

See Sudara(2016): [Rails Performance and the root of all evil](http://blog.scoutapp.com/articles/2016/05/09/rails-performance-and-the-root-of-all-evil) for a more in depth
discussion.


Let's look at the first step: what is a "performance problem" in Web Development?
We are concerned with delivering a whole webpage to the end user. From the end users
perspective there really is only one value to measure: I clicked on something, how long
did it take for the next page to load.  We will call this the "response time".

At least since 2004, when Steve Souders book "High Performance Web Sites" came out
web performance has been discussed a lot in the web developer community. Measuring
tools were developed, workflows were changes, frameworks were adapted to take performance
into account. Today we can use all this knowledge and obtain results easily.  The necessary
tools are all there, we just have to use them properly.

## Measuring Performance

Let's start with a very general rule of thumb for performance:

We want the whole web page to load within a second.  We expect to
need about half of that (500ms) for loading extra assets like
javascript files, css, images.  We will set aside another 200ms for
shipping data across the network, which leaves us with 300ms time to
render out the first HTML document from our Rails App.


### Web Developer Tools in your Browser

Modern Browsers all come with extensive developer tools, which let you
analyze your webpage right in the browser.

An important tool is the network view:

![network view firefox](images/network-view-firefox.png)

You can focus in on the loading of the html document itself,
and look at the timings:

![network view firefox: timings](images/network-timings.png)

Here the time "waiting" for the first byte is high.
This is a performance problem in the Rails App itself. Here
caching might help.

### Webpagetest

Web Page Test is an open source project that you can run on your own servers.
Our you can use the online version to analyze your projects:


![https://www.webpagetest.org/](images/webpagetest.png)


[https://www.webpagetest.org/](https://www.webpagetest.org/)

If the time to "first byte" is high, you have a problem when generating
the first HTML document, right in the Rails app.  Here caching might help.


### Google PageSpeed Insights

Google also offers a performance analysis tool, with
a separate analysis for mobile and desktop:


![https://developers.google.com/speed/pagespeed/insights/](images/pagespeed.png)


[https://developers.google.com/speed/pagespeed/insights/](https://developers.google.com/speed/pagespeed/insights/)



### rack-mini-profiler

This gem helps you analyze where your Rails App spends time.

![https://github.com/MiniProfiler/rack-mini-profiler](images/rack-mini-profiler.png)


[https://github.com/MiniProfiler/rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)

See [RailsCast #368](http://railscasts.com/episodes/368-miniprofiler?view=asciicast) for a good introduction.

The Mini Profiler only measures the server side: the time spent in the rails app to generate
the webpage.  So we need to compare the numbers Mini Profiler gives us to the
300ms threshold defined above.



## Example App

We will use a portfolio site as an example app.  All the screenshots
above already show this example app.  We will focus on the projects show action.

If you look at the miniprofiler above, a first glance rendering
the view takes too long: 450ms is spent there.
118ms are spent in rendering one `_collaborator` partial.  So this seems a promising
place to start optimizing.

Caching is deactivated by default in the development environment. 
You have to activate it if you want to try this out in development:


```
#config/environments/development.rb

[...]
config.action_controller.perform_caching = true
[...]
```

You have to decide on a cache store, for example in-memory:


```
   require 'active_support/core_ext/numeric/bytes'
   config.cache_store = :memory_store, { size: 64.megabytes }
```


### caching the project show view


add this around the project view:

```
<% cache @project do %>
<% end %>
```

The result is stunning:

![https://github.com/MiniProfiler/rack-mini-profiler](images/rack-mini-profiler-faster.png)


tbc...

See Also
--------

* [Rails Guide: Caching](http://guides.rubyonrails.org/caching_with_rails.html)
