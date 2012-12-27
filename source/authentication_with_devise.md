Authentication with Devise
==========================

bla bla bla

After reading this guide you will 

* understand ....
* be able to do ....

-----------------------------------------------------------------

Gems and Bundler
----------------

### gem

* rubygems is the package manager for ruby
* a gem has a name  (e.g. rake) and a version (e.g. 0.9.2.2)
* [what is a gem](http://docs.rubygems.org/read/chapter/24)
* find 47.000 gems at [rubygems.org](http://rubygems.org/)


### the problem

![bundler](images/bundler-small.png)

* you write an app
* using 100 gems
* then deploy it to a server
* where all theses gems are present in slightly different versions

### the solution

* `Gemfile` : define which gems + versions you want
* run `bundle install`
* installs gems, writes `Gemfile.lock`
* versions are now locked!
* deploy, run `bundle install` on the production server
* exact same versions are now installed


### defining versions

``` ruby
gem "devise"
gem "rails", "4.0.0.beta"
gem "rack",  ">=1.0"
gem "thin",  "~>1.1"
gem "nokogiri", :git => "git://github.com/tenderlove/nokogiri.git"
```

### Gemfile.lock

```
devise (2.1.0)
  bcrypt-ruby (~> 3.0)
  orm_adapter (~> 0.0.7)
  railties (~> 3.1)
  warden (~> 1.1.1)
```



### gems and rails

* configuration for a gem: `config/initializers/devise.rb`
* gem may install generators: `rails generate`
* gem may install rake tasks: `rake -T`


Ressources
----------

![Railscast no 209](images/209-devise-revised.png)

* [Railscast no 209](http://railscasts.com/episodes/209-devise-revised?view=asciicast)
