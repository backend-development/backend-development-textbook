# Rails: Database and Models

Models are the basic classes of a Rails Project. The
data is actually stored in a relational database.

After working through this guide you should

- Understand how ActiveRecord works
- Understand what Database Migrations are

The examples were inspired by "Rails for Zombies", which used to be a free Rails online course.
Sadly it is no longer available.

---

## Models and Databases

In an object-oriented programming language like Ruby we represent
things in the real world with objects in our program. For example if you are
building an application for project management, you might
have objects of classes `Project` and `WorkPackage` and `User`.
These classes also implement the "Business Logic": all the methods
needed for handling projects are actually implemented in the Project class.

To save these objects permanently (often called "persistance")
we use a relational database,
in most cases Postgres or MySQL/MariaDB. Only the data is stored in the database,
not the behaviour (the "Business Logic" mentioned above).

Here we hit on an old problem in computer science: storing
objects into a relational database does not work all that well.
This problem is called the
[Object-relational impedance mismatch](https://en.wikipedia.org/wiki/Object-relational_impedance_mismatch)
and has been discussed since the early 1980s.

### ORMs

Today there exist several Design Patterns and Libraries for solving this.
The solution is called an Object Relational Mapper or ORM.

Two Patterns used in Rails for this problem are ActiveRecord and ObjectMapper, both
described by Fowler in his 2003 book [Patterns of Enterprise Application Architecture](https://martinfowler.com/books/eaa.html).
ActiveRecord is the default solution used in Rails, we will look into it in detail here.

## ActiveRecord Basics

Rails implements the Active Record pattern in a class called `ActiveRecord`.
All the models in a Rails project inherit from `ActiveRecord`.

```ruby
# file app/models/thing.rb
class Thing < ApplicationRecord
end


# file app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
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

### Conventions

Rails has several conventions regarding ActiveRecord and the database:

- The model class is written in "pascal case", and uses a singular noun: `Course`
- The table in the database is written in "snake case", and uses the plural of this noun: `courses`
- The table contains an integer attribute `id` as its primary key
- All the attributes from the database table will show up as properties of the model in Rails automatically
- Two extra properties are added: `created_at` and `updated_at`.
- If there's an 1:n relationship between two models, the table on the "one" side will contain a foreign key like so:
  - table `users` and table `phones` (one user has many phones)
  - table `phones` contains `user_id` that references `users.id`
- If there's a n:m relationship between two models, there will be a join table like so:
  - table `users` and table `projects` (one user has many projects, one project has many users)
  - table `projects_users` contains `user_id` and `project_id` (and nothing else)
  - there is no class in Rails to represent the join table

### Not following Conventions

If you stick to these conventions, building the web app will be very easy.

You can deviate from these conventions, but this takes some extra configuration and programming work.

Here is one scenario where deviating from the conventions might make sense:
You are building a Rails app to replace an old php app, but you want to
keep using the same database. You can start with the models
in Rails configured to fit with your old database, and then refactor and migrate towards
the Rails conventions step by step.

## The Model

Look at the model generated in file `app/models/tweet.rb`. Later you will add validations, associations to other models and the business logic here.

### The model in the console

You can use the Rails console to work with
the model interactively. This is similar to the ruby console `irb`
but with your Rails app already loaded.
Any changes you make are really written
to the development database!

- `rails console`

if you just want to play around and not make changes to the database use

- `rails console --sandbox`

instead.

### Finding a model

The database table always has a primary key `id`. You can use this
key to find a specific record:

![using find in the Rails console](images/rails_console_find.png)

When you type in `Tweet.find(1)` into the Rails console, you get two answers:

First (in color) it shows you the SQL query sent to the database. In this case
`SELECT "tweets".* FROM "tweets" WHERE "tweets"."id" = ? LIMIT ?`. You can see
that prepared statements are used, and that a limit is always placed on the number
of answers.

After the Arrow (`=>`) the Rails console shows the return value of the command
you typed in. Here this is an object. The console prints out the details of this
object using the `inspect` method.

§

From now on we will use this slightly shortended format to show Rails console
input and output:

```ruby
railsconsole> Tweet.find(1)
=> #<Tweet id: 1, status: "Where can I get a good bite to eat?", zombie: "Ash">
```

(We will leave out the SQL, and some timestamps.)

### Accessing the properties

You can access the properties of the model object as if it were a hash
or through method names:

```ruby
railsconsole> t = Tweet.find(3)
=>  #<Tweet id: 3, status: "I just ate some delicious brains.", zombie: "Jim">
railsconsole> t.status
=> "I just ate some delicious brains."
railsconsole> t[:status]
=> "I just ate some delicious brains."
railsconsole> t.zombie
=> "Jim"
railsconsole> t[:zombie]
=> "Jim"
```

### CRUD = Create, Read, Update, Delete

Let's see how ActiveRecord implements the four important
capabilities of persistance:

### Create

```ruby
t = Tweet.new
t.status = "I <3 brains."
t.save
```

With `new` you create a new object just in memory. It is not stored in the
database yet and does not have an `id` yet. You can set its properties.
The `save` method tries to save it to the database.

§

On the Rails console you can see how the properties are `nil` in the beginning.
After saving to the database some of the properties are set:

```ruby
railsconsole> t = Tweet.new
 => #<Tweet id: nil, status: nil, zombie: nil, created_at: nil, updated_at: nil>
 railsconsole> t.status = "I <3 brains."
 => "I <3 brains."
 railsconsole> t.save
   (0.1ms)  begin transaction
  Tweet Create (1.8ms)  INSERT INTO "tweets" ("status", "created_at", "updated_at") VALUES (?, ?, ?)  [["status", "I <3 brains."], ["created_at", "2020-11-24 09:20:15.931090"], ["updated_at", "2020-11-24 09:20:15.931090"]]
   (1.7ms)  commit transaction
 => true
railsconsole> t
 => #<Tweet id: 4, status: "I <3 brains.", zombie: nil, created_at: "2020-11-24 09:55:37", updated_at: "2020-11-24 09:55:37">
```

### Read

There are many ways to read data from the database. We already saw `find` which
uses the primary key and always returns one object. The method `where` is used for more general `select - where` SQL statements.

```ruby
t1 = Tweet.find(3)
t2 = Tweet.where("created_at > '2020-10-01'")
t3 = Tweet.where(zombie: 'Ash')
```

§

In the Rails console you can see the return values: `where` returns serveral objects in the end.

```ruby
railsconsole> t1 = Tweet.find(3)
  Tweet Load (0.3ms)  SELECT  "tweets".* FROM "tweets" WHERE "tweets"."id" = ? LIMIT ?  [["id", 3], ["LIMIT", 1]]
 => #<Tweet id: 3, status: "I just ate some delicious brains.", zombie: "Jim", created_at: "2020-11-24 09:26:48", updated_at: "2020-11-24 09:26:48">
railsconsole> t2 = Tweet.where("created_at > '2020-10-01'")
  Tweet Load (0.5ms)  SELECT  "tweets".* FROM "tweets" WHERE (created_at > '2020-10-01') LIMIT ?  [["LIMIT", 11]]
 => #<ActiveRecord::Relation [#<Tweet id: 1, status: "I <3 brains.", zombie: nil, created_at: "2020-11-24 09:20:15", updated_at: "2020-11-24 09:20:15">, #<Tweet id: 2, status: "Where can I get a good bite to eat?", zombie: "Ash", created_at: "2020-11-24 09:26:26", updated_at: "2020-11-24 09:26:26">, #<Tweet id: 3, status: "I just ate some delicious brains.", zombie: "Jim", created_at: "2020-11-24 09:26:48", updated_at: "2020-11-24 09:26:48">]>
railsconsole> t3 = Tweet.where(zombie: 'Ash')
  Tweet Load (0.3ms)  SELECT  "tweets".* FROM "tweets" WHERE "tweets"."zombie" = ? LIMIT ?  [["zombie", "Ash"], ["LIMIT", 11]]
 => #<ActiveRecord::Relation [#<Tweet id: 2, status: "Where can I get a good bite to eat?", zombie: "Ash", created_at: "2020-11-24 09:26:26", updated_at: "2020-11-24 09:26:26">]>
```

### Update

With update - as with `new` before - we see the difference between the
object in memory (`t`) which can be changed and the object in the database
which is only changed when t is saved back to the database.

```ruby
t = Tweet.find(3)
t.zombie = "EyeballChomper"
t.save
```

In the Rails console you can see that for every change in the object
the property `updated_at` is automatically set.

```ruby
railsconsole> t = Tweet.find(3)
  Tweet Load (0.4ms)  SELECT  "tweets".* FROM "tweets" WHERE "tweets"."id" = ? LIMIT ?  [["id", 3], ["LIMIT", 1]]
 => #<Tweet id: 3, status: "I just ate some delicious brains.", zombie: "Jim", created_at: "2020-11-24 09:26:48", updated_at: "2020-11-24 09:26:48">
railsconsole> t.zombie = "EyeballChomper"
 => "EyeballChomper"
railsconsole> t.save
   (0.2ms)  begin transaction
  Tweet Update (0.6ms)  UPDATE "tweets" SET "zombie" = ?, "updated_at" = ? WHERE "tweets"."id" = ?  [["zombie", "EyeballChomper"], ["updated_at", "2020-11-24 09:32:52.071511"], ["id", 3]]
   (1.2ms)  commit transaction
 => true
```

### Delete

To delete both the object in memory and in the database use `destroy`.

```ruby
t = Tweet.find(3)
t.destroy
```

On the console you can see how `destroy` is translated to `DELETE` in SQL.

```ruby
railsconsole> t = Tweet.find(3)
  Tweet Load (0.3ms)  SELECT  "tweets".* FROM "tweets" WHERE "tweets"."id" = ? LIMIT ?  [["id", 3], ["LIMIT", 1]]
 => #<Tweet id: 3, status: "I just ate some delicious brains.", zombie: "EyeballChomper", created_at: "2020-11-24 09:26:48", updated_at: "2020-11-24 09:32:52">
railsconsole> t.destroy
   (0.1ms)  begin transaction
  Tweet Destroy (0.7ms)  DELETE FROM "tweets" WHERE "tweets"."id" = ?  [["id", 3]]
   (1.1ms)  commit transaction
 => #<Tweet id: 3, status: "I just ate some delicious brains.", zombie: "EyeballChomper", created_at: "2020-11-24 09:26:48", updated_at: "2020-11-24 09:32:52">
```

### Chaining ActiveRecord methods

Let's look at the example of using `where` again: the return value was of class `ActiveRecord::Relation`:

```ruby
railsconsole> t3 = Tweet.where(zombie: 'Ash')
  Tweet Load (0.3ms)  SELECT  "tweets".* FROM "tweets" WHERE "tweets"."zombie" = ? LIMIT ?  [["zombie", "Ash"], ["LIMIT", 11]]
 => #<ActiveRecord::Relation [#<Tweet id: 2, status: "Where can I get a good bite to eat?", zombie: "Ash", created_at: "2020-11-24 09:26:26", updated_at: "2020-11-24 09:26:26">]>
```

This class also supports all the ActiveRecord methods. This means
we can chain several `where`s together:

```ruby
tweets = Tweet.where("created_at > '2020-10-01'").where(zombie: 'Ash')
```

§

In fact there are many more methods we might want to use for chaining:

```ruby
Tweet.limit(3)
Tweet.order(:zombie)
Tweet.select(:created_at, :zombie, :status)
Tweet.where("created_at > '2020-10-01'").
  where(zombie: 'Ash').
  order(:zombie).limit(3)
```

(Normally the dot is placed in front of the method when chaining. Here
it is placed at the end, to enable copy-and-paste to the Rails console)

§

You can use the method `to_sql` to see the SQL Statement produced by the chained methods:

```ruby
railsconsole> Tweet.select(:created_at, :zombie, :status).
  where("created_at > '2020-10-01'").
  where(zombie: 'Ash').
  order(:zombie).
  limit(3).to_sql
 => SELECT  "created_at", "zombie", "status"
       FROM "tweets"
       WHERE (created_at > '2020-10-01')
       AND "zombie" = 'Ash'
       ORDER BY "zombie" ASC
       LIMIT 3
```

§

The order of the methods is not relevant. You can also save an intermediate step to
a variable, and then chain more methods to that variable later on:

```ruby
railsconsole> query = Tweet.where("created_at > '2020-10-01'").
  order(:zombie).limit(3)
railsconsole> query.select(:created_at, :zombie, :status).
  where(zombie: 'Ash').to_sql
 => SELECT  "created_at", "zombie", "status"
      FROM "tweets"
      WHERE (created_at > '2020-10-01')
      AND "zombie" = 'Ash'
      ORDER BY "zombie" ASC
      LIMIT 3
```


## Database

### A word on generators

Rails comes with several commands for the command line.

```
$ rails --help
The most common rails commands are:
 generate     Generate new code (short-cut alias: "g")
 console      Start the Rails console (short-cut alias: "c")
 server       Start the Rails server (short-cut alias: "s")
 test         Run tests except system tests (short-cut alias: "t")
 test:system  Run system tests
 dbconsole    Start a console for the database specified in config/database.yml
              (short-cut alias: "db")
```

First we will
use a generator that will help us generate some code.

### How to build a Table

To build the first model and its corresponding database table, use the model generator:

`rails generate model tweet status zombie`

This will generate a Model `Tweet` and a migration to create table `tweets`.

Have a look at the migration that was generated in `db/migrate/*create_tweets.rb`.
You can edit this migration now - but not later! Run the migration on the command line with `rails db:migrate`. This will run the appropriate `CREATE TABLE` statement in your database.

Look at the model generated in file `app/models/tweet.rb`. Add validations, associations to other models and the business logic here.

### Database Migrations

During Development the database schema will change just as much as
the code will change. And both changes belong together: if I push out
a code change to my fellow developers without the db schema changes,
they will not be able to use the code.

Rails offers "Database Migrations" to cope with this fact.

§

A "Migration" is a (small) change in the database schema. The change is
described in Ruby and saved to a file in the folder `db/migrations`.
The files are identified by a timestamp and a unique name, for example:

```
20201031100433_create_venues.rb
20201031100442_create_events.rb
20201031100501_add_video_link_to_events.rb
```

The first two of these migrations were generated by the model generator,
the last one by `rails generate migration AddVideoLinkToEvent`.

§

The model generator creates a migration for creating a table:

```ruby
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

§

Use `rails` on the commandline to apply this migration to the existing database:

- `rails db:migrate` # apply all open migrations
- `rails db:rollback` # roll back last migration

A word of warning: you never, ever need to change a migration after
using, commiting and pushing it. You only ever add new migrations!

### a real world example:

The following output is from upgrading gitlab. Gitlab
is written in Rails. Here we can see three migrations being applied to
the existing database:

```
== 20191120084627 AddEncryptedFieldsToApplicationSettings: migrating ==========
-- add_column(:application_settings, "encrypted_akismet_api_key", :text)
 -> 0.0013s
-- add_column(:application_settings, "encrypted_akismet_api_key_iv", :string, {:limit=>255})
 -> 0.0007s
-- add_column(:application_settings, "encrypted_elasticsearch_aws_secret_access_key", :text)
 -> 0.0007s
-- add_column(:application_settings, "encrypted_elasticsearch_aws_secret_access_key_iv", :string, {:limit=>255})
 -> 0.0008s
-- add_column(:application_settings, "encrypted_recaptcha_private_key", :text)
 -> 0.0008s
-- add_column(:application_settings, "encrypted_recaptcha_private_key_iv", :string, {:limit=>255})
 -> 0.0007s
-- add_column(:application_settings, "encrypted_recaptcha_site_key", :text)
 -> 0.0007s
-- add_column(:application_settings, "encrypted_recaptcha_site_key_iv", :string, {:limit=>255})
 -> 0.0007s
-- add_column(:application_settings, "encrypted_slack_app_secret", :text)
 -> 0.0007s
-- add_column(:application_settings, "encrypted_slack_app_secret_iv", :string, {:limit=>255})
 -> 0.0007s
-- add_column(:application_settings, "encrypted_slack_app_verification_token", :text)
 -> 0.0007s
-- add_column(:application_settings, "encrypted_slack_app_verification_token_iv", :string, {:limit=>255})
 -> 0.0007s
== 20191120084627 AddEncryptedFieldsToApplicationSettings: migrated (0.0095s) =

== 20191120115530 EncryptPlaintextAttributesOnApplicationSettings: migrating ==
== 20191120115530 EncryptPlaintextAttributesOnApplicationSettings: migrated (0.4133s)

== 20191122135327 RemovePlaintextColumnsFromApplicationSettings: migrating ====
-- remove_column(:application_settings, "akismet_api_key")
 -> 0.0010s
-- remove_column(:application_settings, "elasticsearch_aws_secret_access_key")
 -> 0.0006s
-- remove_column(:application_settings, "recaptcha_private_key")
 -> 0.0006s
-- remove_column(:application_settings, "recaptcha_site_key")
 -> 0.0006s
-- remove_column(:application_settings, "slack_app_secret")
 -> 0.0006s
-- remove_column(:application_settings, "slack_app_verification_token")
 -> 0.0007s
== 20191122135327 RemovePlaintextColumnsFromApplicationSettings: migrated (0.0045s)
```

## On Documentation

You could have learned all this and more from
the Rails Guides: [ActiveRecord Basics](https://guides.rubyonrails.org/active_record_basics.html), [Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html) and [Active Record Migrations](https://guides.rubyonrails.org/active_record_migrations.html).
Set a bookmark for the guides now! Use them as a reference from now on!

If you are offline now and again you should have the Ruby and Rails documentation available
locally on your computer. A handy tool for this on mac os x is
[Dash](https://kapeli.com/dash). This is what a Rails Guide looks like in Dash:

![Dash](images/dash-rails-guide.png)

### Further reading

- The Rails Guides give a good introduction to a subject area:
  - Rails Guide: [Active Record Basics](https://guides.rubyonrails.org/active_record_basics.html)
  - Rails Guide: [Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html)
- Use the [Rails API](https://api.rubyonrails.org/) documentation to look up the details:
  - [find](https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
  - [where](https://api.rubyonrails.org/classes/ActiveRecord/QueryMethods.html#method-i-where)
  - [add_column](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) lists all the possible data types for columns
