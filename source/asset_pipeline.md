The Asset Pipeline
===================

A web site consist of many more files than just the
HTML documents we have been generating up to now:
css files, javascript files, image files, font files, ...

The asset pipeline is rails' way of preparing 
theses files for publication using the current state
of knowledge regarding web performance.

By referring to this guide, you will be able to:

* keep your assets in the right place
* have all your assets compiled and minified for production

REPO: Fork the [example app 'recipes'](https://github.com/backend-development/rails-example-recipes) and try out what you learn here.


---------------------------------------------------------------------------

Web Performance
----------------

What do we mean by 'web performance'?  From the viewpoint of one user,
the crucial value is the time it takes from requesting a page (by clicking a link
or button, or typing in an URL) to having the page displayed and interactive in your browser.
We will call this the 'response time'.

From the publishers point of view it might also encompass the question of
how many uses you can serve (with acceptable response time) on a given
server.  If you look at the question of how to server more users in case
of more demand you enter the realm of 'scalability'.  This is a more advanced
question that goes beyond the scope of this guide.

### Myths About Performance

If you have never studied this subject you might still have
an intutation about where performance problems come from.
Many beginners are fascinated by details of their programming
language like: will using more variables make my program slower?
or: is string concatenation faster than string interpolation.

These 'micro optimizations' are hardly ever necssary with modern
programming languages and computers.  Using rails, postgres and any
of hundres of hosting or cloud services you will have no trouble
serving hundreds of users a day and achieving adequate performance for
all of them.

Trying to 'optimize' you code without having a problem at all
or without knowing which part of the system is causing the performance
problem will make your code worse, not better.

Donald Knuth stated this quite forcefully:

"The real problem is that programmers have spent far too much time worrying about efficiency in the wrong places and at the wrong times; **premature optimization is the root of all evil**" -- [Donald Knuth](https://en.wikiquote.org/wiki/Donald_Knuth#Computer_Programming_as_an_Art_.281974.29)

Only after you have measured the performance factors that are
relevant to your project, and only after you have found out
which part of the system is causing theses factors to go over
the threshold of acceptable values, only then can you truly
start to 'optimize'.  

### Measuring Web Performance 

The "exceptional performance" group at yahoo published the browser addon
`yslow` in 2007. It measures performance and displays the timing
of the different HTTP connections as a "waterfall graph":

![displaying http downloads with yslow](images/network-souders-2008.png)

(Image from Steve Souders [talk at Web 2.0 Expo](http://www.web2expo.com/webexsf2008/public/schedule/detail/3321) in April 2008)

Each bar is one resource being retrieved via HTTP, the x-axis
is a common timeline for all.  The most striking result you can read from
this graph: the backend is only responsible for 5% of the time in this
example!  95% of time are spent loading and parsing javascript and css files
and loading and displaying images!

This graph was later integrated into the built in developer tools
of several browsers, and into the online tool [webpagetest](https://webpagetest.org/).

**Firefox**

![network view in firefox](images/network-view-firefox.png)

**Chrome**

![network view in chrom](images/network-view-chrome.png)

NOTE: This guide is still a work in progress


### Rules...

*   Less HTTP Requests
*   Use a Content Delivery Network
*   Avoid empty src or href
*   Add an Expires or a Cache-Control Header
*   Gzip Components
*   Put StyleSheets at the Top
*   Put Scripts at the Bottom
*   Avoid CSS Expressions...



### ...more Rules...

*   Make JavaScript and CSS External
*   Reduce DNS Lookups
*   Minify JavaScript and CSS
*   Avoid Redirects
*   Remove Duplicate Scripts
*   ...


### rails can help

* Minify JavaScript and CSS
* Create CSS Sprites
* Set Expires Header for static assets



Rails Environments
-------------------


### Three pre-defined Environments

* development - optimized for debugging
* testing
* production - optimized for speed, stability


### How to Configure

* config/environments/development.rb
* config/environments/production.rb


### How to use different environment

* webrick server: `rails server -e production`
* Rake tasks: add `RAILS_ENV="production"` at the end of the command.
* Rails console: `rails console production`


### Asset Pipeline (since Rails 3)

*   source in `app/assets/*`
*   `rake assets:precompile`
*   assets in `public/assets/*`
*   can be served by web server, without going through the rails stack
*   `public/assets/manifest.yml`
* files look like this: `application-107e9bb2ab22174acce34bbbbe8f6d7f.css`
* expires header is set far into the future
* change in file --> new file name

### all git repositories are created equal in dignity and rights

* we've been using a centralized model, pushing to a remote on repos.mediacube.at
* today we need two working copies, but we can't push to the `origin`
* clone a local git repository:
* `git clone /path/to/the/repository new_directory_name`
* origin will point back to old repository
* push and pull as usual!


### example app 'rezepte'

``` sh
cd /my/work
git clone ssh://repos.mediacube.at/opt/git/web_2012/example/rezepte.git/ rezepte_development
git clone /my/work/rezepte_development rezepte_production
```

### remember!

every significant step in development should be a commit!


The Asset Pipeline
---------------


![Asset Pipeline](images/asset-pipeline.svg)



Compile to the Web
-------------------

* compiling to css
* compiling to javascript



### compiling to css

* [sass](http://sass-lang.com/) - default in ruby
* [less](http://lesscss.org/)
* [stylus](http://learnboost.github.com/stylus/)


### no { } and no ;

``` sass
h1
  color: black
  background-color: yellow

p
  text-align: justify
```


### nesting

``` sass
h1 strong
  color: red

nav
  a:link, a:visited, a:active
    text-decoration: none
  a:link
    color: blue
  a:visited
    color: white
```


### variables and computation

``` sass
$blue: #3bbfce
$x: 16px

.content-navigation
  border-color: $blue
  color: darken($blue, 9%)

.border
  padding: $x / 2
  margin: $x / 2
  border-color: $blue
```



### mixins for reusing css-code

``` sass
@mixin left($dist)
  float: left
  margin-left: $dist

#data
  @include left(10px)
```


### automatically create sass from css after every change

``` sass
### for one file in the current directory
sass --watch style.scss:style.css

### for a whole directory of files
sass --watch stylesheets/sass:stylesheets/compiled
```


### sass comes with a reverse compiler

``` sass
sass-convert --from css --to sass style.css > style.sass
```


Further Reading
--------------

* Souders(2007): High Performance Web Sites. O'Reilly. ISBN-13: 978-0596529307.
* Souders(2009): Even Faster Web Sites. O'Reilly. ISBN-13: 978-0596522308.
