Caching
=======================

What is even better than having a really fast web
server, framework, programming language that creates
your web page?  Not having to create and load the page at all
becaus it's already there in your browser cache.

After working through this guide you will:

* be aware of many levels of caches that influence your web app
* be able to configure rails for caching

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




What is Caching
---------------



Asset Pipeline
------------

When using Apache + Passenger:







See Also
--------

* [Rails Guide: Caching](http://guides.rubyonrails.org/caching_with_rails.html)
