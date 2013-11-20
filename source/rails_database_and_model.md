Rails: Database and Models
==========================

Models are the basic Classes of a Rails Project.  The
data is actually stored in a relational database.

After working through this guide you should

* Understand how ActiveRecord works
* Understand what Database Migrations are
* Be able to create models with associations to other models
* Be able to write validations to check data before it is saved in a model

-------------------------------------------------------------


Models and Databases
--------------------

In a modern programming language like rails we represent 
things in the real world with objects. For example if you are
building a web application for project management, you will
have objects of classes Project, and WorkPackage, and User.

To save these objects permanently (often called "persistance") 
we use a relational Database,
in most cases Postgres or MySQL/MariaDB.

Here we hit on an old problem in computer science: storing
objects into a relational database does not work all that well.
This problem is called the 
[Object-relational impedance mismatch](http://en.wikipedia.org/wiki/Object-relational_impedance_mismatch)
and has been discussed since the early 1980ies.

Today there exist several Design Patterns and Libraries for solving this.
The solution is called an Object Relational Mapper or ORM.

Two Patterns used in Rails for this problem are ActiveRecord and ObjectMapper, both first
described by Fowler in his 2003 book [Patterns of Enterprise Application Architecture](http://martinfowler.com/books/eaa.html).
ActiveRecord is the default solution used in Rails, we will look into it in detail here.


ActiveRecord
------------

Rails implements the Active Record pattern in a class called `ActiveRecord`.
All the models in a rails project inherit from `ActiveRecord`.


``` ruby
class Thing < ActiveRecord::Base
end
```



### The Mapping

A quick overview of how Objects and Database relate when using
ActiveRecord in Rails:

```
Database                           Ruby on Rails
---------------------------        --------------------------
table courses                      class Course 
  in the Database                    in file app/models/course.rb
one row in the table               one object of the class Course
an attibute in the table           a property of the object
SELECT * FROM courses WHERE id=7   Course.find(7)
```

Rails has several conventions regarding ActiveRecord and the database:

* The Model Class is written in first-letter-uppercase, and uses a singular noun: `Course`
* The table in the database is written in lowercase, and uses the plural of this noun: `courses`
* The table contains an integer attribute `id` as its primary key
* All the attributes from the database table will show up as properties of the model in rails automatically
* If there's an 1:n relationship between two models, the table on the "one" side will contain a foreign key like so:
   * table `users`  and table `phones`  (one user has many phones)
   * table `phones` contains `user_id` that references `users.id`
* If there's a n:m relationship between two models, there will be a join table  like so:
   * table `users`  and table `projects`  (one user has many projects, one project has many users)
   * table `projects_users` contains `user_id` and `projects_id` (and nothing else)
   * there is no class in rails to represent the join table 

If you stick to these conventions building the web app will be very easy.  You 
can deviate from these conventions, but this takes some extra configuration and programming work.

One scenarion where deviating from the conventions might make sense is when
you build a rails app to replace an old php app. You can start with the models
in rails configured to fit with your old database, and then refactor and migrate towards
the rails conventions step by step.

### How to build a model

To build the first model and its corresponding database table,
you can use the scaffold generator.
You need to work on the command line using the commands
`rails` and `rake`.

* `rails generate scaffold tweet status:string zombie:string`
   * This will generate a Model `Tweet` and a migration to create table `tweets`
* look at the migration that was generated in `db/migrate/*create_tweets.rb`
* you can edit the migration now - but not later!
* run the migration: `rake db:migrate`
   * this will run the appropriate `CREATE TABLE` statement in your database
* look at the model generated in `app/models/tweet.rb`
* add validations, associations to the model

### Database Migrations

During Development the database schema will change just as much as
the code will change. Changes to both are interdependent: if I push out
a code change to my fellow developers without the db schema changes,
they will not be able to use the code.

Rails offers "Database Migrations" to cope with this fact.

A "Migration" is a (small) change in the database schema. The change is
described in ruby and saved to a file in the folder `db/migrations`.
The files are identified by a timestamp and a uniqe name, for example:

```
20131031100433_create_venues.rb  
20131031100442_create_events.rb  
20131031100501_add_venue_ref_to_events.rb
```

The first two of these migrations were generated by the scaffold,
the last one by `rails generate migration AddVenueRefToEvent`.

The scaffold creates a migration for creating a table:

``` Ruby
class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.datetime :start_time
      t.datetime :stop_time
      t.boolean :free

      t.timestamps
    end
  end
end
```

Use `rake` to apply this migration to the existing database:

* `rake db:migrate`  # apply all open migrations
* `rake db:rollback` # roll back last migration

A word of warning:  you never, ever need to change a migration after
using and commiting it.  You only ever add new migrations!

### the Model on the console

You can use the rails console to work with
the model interactively.  This is similar to the ruby console `irb`
but with your rails app already loaded. 
Any changes you make are really written
to the development database!

* `rails console`

### Learn from Zombies

Now do 'Rails for Zombies' Episode #1

![Rails for Zombies 1](images/rails-for-zombies-1.jpg)

### Validations

* validations are declared on the model
* checked every time data is saved to the database
* if data does not conform, error are available through the object

### Validations


``` ruby
> t = Tweet.new
=> #<Tweet id: nil, status: nil, zombie: nil>
> t.save
=> false
> t.errors
=> {:status=>["can't be blank"]}
> t.errors[:status]
=> "can't be blank"
```


### 1:n Associations #


### 1:n Associations

* 1:n associations are declared in the model with `belongs_to` and `has_many`:
* Zombie has many tweets, Tweet belongs_to zombie.
* add the foreign key to the appropriate database table using a migration!
* `add_column    :tweets, :zombie_id, :integer`
* both directions are now available in the objects:
* `t = Tweet.find(7); z = t.zombie`
* `z = Zombie.find(1); z.tweets.each{ |t|  puts t.status }`


Rails for Zombies
------------------

Now do 'Rails for Zombies' Episode #2

![Rails for Zombies 2](images/rails-for-zombies-2.jpg)

### On Documentation

You should have the ruby and rails documentation available
on your computer at all times.  A handy tool for this on mac os x is
[Dash](http://kapeli.com/dash).  This is what a Rails Guide looks like in Dash:


![Dash](images/dash-rails-guide.png)

### Further reading

* The Rails Guides give a good introduction to a subject area:
* Rails Guide: [Active Record Query Interface](http://guides.rubyonrails.org/active_record_querying.html)
* Rails Guide: [Active Record Validations and Callbacks](http://guides.rubyonrails.org/active_record_validations_callbacks.html)
* Rails Guide: [Active Record Associations](http://guides.rubyonrails.org/association_basics.html)
* Use the API Dock to look up the details:
* Rails @ API Dock: [find()](http://apidock.com/rails/ActiveResource/Base/find/class)
* Rails @ API Dock: [ActiveRecord Validations](http://apidock.com/rails/v2.0.3/ActiveRecord/Validations/ClassMethods/validates_presence_of)
* Rails @ API Dock: [ActiveRecord Associations](http://apidock.com/rails/v3.2.8/ActiveRecord/Associations/ClassMethods)
