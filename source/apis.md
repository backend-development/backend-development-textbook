APIs
=======================

After working through this guide you will:

* know about the thinking behind REST APIs and JSON API
* be able to configure your existing controllers to offer resourses as JSON
* be able to set up an API for your rails app that is separate from existing controllers

REPO: You can study the [code](https://github.com/backend-development/api_sample_app) and try out [the demo](https://dry-cove-38472.herokuapp.com/) for the example described here.

---------------------------------------------------------------------------

What is an API
---------------


## REST

The acronym REST was coined by Roy Fielding in his dissertation. When describing
the architecture of the web, and what made it so successfull on a technical level,
he desribed this architecture as "Representational State Transfer".

A REST API allows to access and manipulate textual representations of Web resources using a uniform and predefined set of stateless operations. 

"Web resources" were first defined on the World Wide Web as documents or files identified by their URLs, but today they have a much more generic and abstract definition encompassing every thing or entity that can be identified, named, addressed or handled, in any way whatsoever, on the Web.




## JSON API


Rendering JSON
---------


See Also
--------


* [Rails Guide: Rendering JSON in Action Controller Overview](http://edgeguides.rubyonrails.org/action_controller_overview.html#rendering-xml-and-json-data)
* [Rails Guide: Using Rails for API-only Applications](http://edgeguides.rubyonrails.org/api_app.html)
* [Fielding, Roy(2000): Architectural Styles and the Design of Network-based Software Architectures](http://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm). Dissertation. University of California/Irvine, USA.
* [Tilkov(2007): A Brief Introduction to REST](https://www.infoq.com/articles/rest-introduction)
