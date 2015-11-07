The Asset Pipeline
===================

bla bla bla

By referring to this guide, you will be able to:

* keep your assets in the right place
* have all your assets compiled and minified for production

---------------------------------------------------------------------------


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


Web Performance
----------------

### pre-modern area

* performance of the backend
* myths about performance: image slicing



### modern area

* work of the "exceptional performance" group at yahoo: yslow
* Souders(2007): High Performance Web Sites
* "front end view" of performance


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


