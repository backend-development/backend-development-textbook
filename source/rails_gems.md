Some Gems for Rails 
===========================

This guide lists a few valuable gems for
your first Rails Project.

After reading this guide you will

* understand how gems are installed
* understand how bundler handles dependencies
* be able to configure the gems you use
* be able to deliberately chose version numbers for your gems
* know a few intresting gems for your next rails project

-----------------------------------------------------------------

Gems and Bundler
----------------

### gems

Code reuse is a deciding factor for programmer productivity. In Ruby
the unit of reuse is called a `gem`. `rubygems` is the package manager for ruby,
it let's you install gems on your system.

A gem has a name  (e.g. `rake`) and a version number (e.g. `10.4.2`).
It can be written in plain ruby or sometimes in ruby and c.  Many gems
depend on system libraries that need to be installed before the gem can
be installed.  For example the [rmagick](https://rubygems.org/gems/rmagick/versions/2.15.4)
gem for image manipulation needs the library `ImageMagick`.

So most of the time installing a gem is as simple as

```bash
> gem install rails_best_practices
Successfully installed rails_best_practices-1.15.7
Parsing documentation for rails_best_practices-1.15.7
Installing ri documentation for rails_best_practices-1.15.7
Done installing documentation for rails_best_practices after 2 seconds
1 gem installed
```

But sometimes you have to do other installations first. 
On your development machine this might look like this:

```bash
# install node on a mac
> brew install nodejs
> gem install uglifier
```

Sometimes you need to set include paths when compiling the c-part of the gem, e.g.:

```bash
> gem install eventmachine 
... error messages ...
In file included from binder.cpp:20:
./project.h:116:10: fatal error: 'openssl/ssl.h' file not found
#include <openssl/ssl.h>
         ^
> brew install openssl
> gem install eventmachine -- --with-cppflags=-I/usr/local/opt/openssl/include
```

In production you probably have to deal with Linux, and you
may not have the right permissions to install system libraries.
A typical example would be:

``` shell
$dev> ssh my.production.machine
$production> sudo apt-get install libmagick++-dev
$production> gem install rmagick
$production> gem install paperclip
```

Now that you have installed the gem once by hand
you can be sure that it can also be reinstalled by bundler.

See also:

* [what is a gem](http://docs.rubygems.org/read/chapter/24)
* find 100.000 gems at [rubygems.org](http://rubygems.org/)

### dependency hell

For a rails project you will be using a lot of gems. This will lead
to two problems:

1. dependency resolution: gem A depends on version 1.1 of gem C, while gem B wants at least version 1.5.  You need to find the right version of every gem in your project that actually fits together
2. different installation: when deploying to a production server, or even just when shareing code with other developers you need to make sure that the same constellation of gems and versions is used on every machine


### bundler saves us

![bundler](images/bundler-small.png)

Bundler is the name of the tool that saves us from dependency hell.
Bundler is itself a gem, so you install it with `gem install bundler`.
Beware: the command you will be using called `bundle`, not bundler.

There is how it works: In every ruby project you write
a `Gemfile` in which you define which gems and (to a certain degree) which versions you want.
When you run `bundle install` bundler will:

* read the Gemfile, 
* pick out compatible versions of all the gems (if possible), 
* install all these gems
* write `Gemfile.lock`

The lock-file contains a complete list of all the gems necessary for
your project, and their version numbers.  These are now locked down,
and will not change!

When deploying to a new development machine or the production server, 
you run `bundle install` and the exact same versions are now installed.


### defining versions

In the Gemfile you can specify which versions should be used.
But don't overdo it!  Bundler does a good job picking versions,
if you specify every version number by hand you are doing too much work.

Some examples of the different ways of specifying version number and source:

``` ruby
# Gemfile
source 'https://rubygems.org'

ruby '2.1.5'

gem 'devise'
gem 'rails', '4.2.5'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
```

The arrow `~>` will only allow an increase in the 
last (right most) number, so `~> 4.1.0` does allow `4.1.17` but not `4.2`.
This is called a pessimistic version constraint, read more about 
it in [the rubygem documentation](http://guides.rubygems.org/patterns/#pessimistic-version-constraint).


### gems and rails

The configuration for a gem is found in the initializer directory,
for example for `devise` the configuration file would be `config/initializers/devise.rb`.

A gem may install new generators for rails, run `rails generate` to see a list
of available generators.

A gem may install rake tasks, run `rake -T` to see a list.


Some Gems
----------

This list is based on [Dwellables statistics on the Rails Rumble 2013](http://www.dwellable.com/blog/Rails-Rumble-Gem-Teardown) and
[coodbeerstartups "Must Have Gems for Development Machine in Ruby on Rails "](http://www.codebeerstartups.com/2013/04/must-have-gems-for-development-machine-in-ruby-on-rails).

### Frontend Stuff for rails

Use rails-assets.org to get javascript libraries.
It is a proxy to Bower, so any library that is available
through Bower is available to rails.

In your gemfile:

```
source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap-sass'
  gem 'rails-assets-angular'
  gem 'rails-assets-leaflet'
end
```

Search for libraries at [https://rails-assets.org](https://rails-assets.org)

### File Upload

Uploading Pictures and displaying them is a common task with two good solutions:

* gem [carrierwave](https://github.com/carrierwaveuploader/carrierwave) or
* gem [paperclip](https://github.com/thoughtbot/paperclip)

Both use the library [ImageMagick](http://www.imagemagick.org/):

* gem [rmagick](https://github.com/rmagick/rmagick) image processing with image magick

You might also want to know how to use ImageMagick on the UNIX commandline: 

* command line tool [convert](http://www.imagemagick.org/script/convert.php) to convert to different formats and
* command line tool [mogrify](http://www.imagemagick.org/script/mogrify.php) to  resize, blur, crop, draw on, flip, join, ... an image and overwrite it.

### Authentication

* gem [devise](https://github.com/plataformatec/devise) for login,
* gem [omniauth](https://github.com/intridea/omniauth) to integrate authentication methods.
* gem [pundit](https://github.com/elabs/pundit) if you need roles and permissions 

### Permalinks

You don't want the database keys to be visible in your URLs?  Use Friendly IDs instead:

* gem [friendlyid](https://github.com/norman/friendly_id)

### Parsing xml and html

* gem [nokogiri](http://nokogiri.org/)

(this is also used by capybara)

### Parsing Markdown

Letting users enter HTML is a dangerous idea - it's really hard to
avoid the security problems.  An alternative is to let them enter
a simpler markup language, like [Markdown](http://en.wikipedia.org/wiki/Markdown).
You store the markdown in your database, and convert it to HTML when displayed using a gem:

* gem [redcarpet](https://github.com/vmg/redcarpet) - see [Railscast #272](http://railscasts.com/episodes/272-markdown-with-redcarpet?view=asciicast)

### Activity Stream

If you want to give users an overview of what happened recently
you can use an activity stream, similar to what you see in facebook.

![activity stream example](images/gem-activity.png)

* gem [public_activity](https://github.com/pokonski/public_activity)

### Admin Backend

Create a Backend for manipulating data with a few lines of code:

![ActiveAdmin Screenshot](images/gem-active-admin.png)

* gem [activeadmin](http://activeadmin.info/)


### Sending Mail

To send mail from Rails use [ActionMailer](http://guides.rubyonrails.org/action_mailer_basics.html).

To see the generated mails in your web browser *instead* of sending them, use the gem [letter_opener](https://github.com/ryanb/letter_opener)

### HTTP Requests

This might be handy for downloading from Webpages or APIs

* gem [curb](https://github.com/taf2/curb)  - the http library curl for ruby

### Using APIs

* gem [octokit](https://github.com/octokit/octokit.rb) - for github
* gem [twitter](https://github.com/sferik/twitter)
* gem [gravatar](https://github.com/sinisterchipmunk/gravatar)
* gem [koala](https://github.com/arsduo/koala) - for facebook
* gem [barometer](https://github.com/attack/barometer) - A multi API consuming weather forecasting superstar
* gem [gmaps4rails](https://github.com/apneadiving/Google-Maps-for-Rails)

### Testing

* gem [factory_girl](https://github.com/thoughtbot/factory_girl) for creating test data.
* gem [capybara](https://github.com/jnicklas/capybara) as the "browser" for acceptance tests, with
* gem [poltergeist](https://github.com/jonleighton/poltergeist) for testing client side javascript.


### Understanding your Code better

![better_errors screenshot](images/gem-better_errors.png)

* gem [better_errors](https://github.com/charliesome/better_errors)

* gem [meta_request](https://github.com/dejan/rails_panel/tree/master/meta_request) - supporting gem for [Rails Panel, a Google Chrome extension for Rails development](https://github.com/dejan/rails_panel)
* gem [annotate](https://github.com/ctran/annotate_models) - inserts the db schema as comments in your model.rb file
* gem [bullet](https://github.com/flyerhzm/bullet) - helps you improve your usage of activerecord queries
* gem [flay](https://github.com/seattlerb/flay) - finds structural similarities in your code, so you can refactor
* gem [rails_best_practices](https://github.com/railsbp/rails_best_practices)


Ressources
----------

* [Ruby Gems](https://rubygems.org/)
* [Bundler](http://bundler.io/)
* the [Ruby Toolbox](https://www.ruby-toolbox.com/) is organized in categories that help you find alternative solutions
* [How does Bundler work, anyway?](https://www.youtube.com/watch?v=4DqzaqeeMgY) talk by Andre Arko at RubyConf 2015
