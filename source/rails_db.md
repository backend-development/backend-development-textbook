# Rails: Database and Migrations

Behind Models in Rails there is a database.

After working through this guide you should

- Understand what Database Migrations are
- Understand how Models relate to Database rows


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

Maybe you have used ORMs in other Languages? Some examples are:

- PHP: [Doctrine](https://www.doctrine-project.org/) and [Propel](https://propelorm.org/)
- Java: [Hibernate](https://hibernate.org/)
- Python: [SQL Alchemy](https://www.sqlalchemy.org/) and [many more](https://www.fullstackpython.com/object-relational-mappers-orms.html)
- JavaScript+Typescript: [Sequelize](https://sequelize.org/), [TypeORM](https://typeorm.io/), [prisma](https://www.prisma.io/) and [many more](https://blog.logrocket.com/best-typescript-orms/#picking-best-typescript-orms)


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

- The model class is written in "pascal case", and uses a singular noun: `Course` or `WorkPackage`
- The table in the database is written in "snake case", and uses the plural of this noun: `courses` or `work_packages`
- The table contains an integer attribute `id` as its primary key
- All the attributes from the database table will show up as properties of the model in Rails automatically
- Two extra properties are added: `created_at` and `updated_at`.


If there's an 1:n relationship between two models, the table on the "one" side will contain a foreign key like so:

- table `users` and table `phones` (one user has many phones)
- table `phones` contains `user_id` that references `users.id`

If there's a n:m relationship between two models, there will be a join table like so:

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

### How to build a first Table - generate

To build the first model and its corresponding database table, use the model generator:

`rails generate model tweet status zombie`

This will generate a Model `Tweet` and a migration to create table `tweets`.
We have not specified any datatypes, therefore status and zombie will
have the default type: string.

Look at the model generated in file `app/models/tweet.rb`. It is empty for now.
We do not need to specify properties or their datatypes here, they will be
derived from the database automatically.


### How to build a first Table - edit migration

Have a look at the migration that was generated in `db/migrate/*create_tweets.rb`.

```ruby
class CreateTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.string :status
      t.string :zombie

      t.timestamps
    end
  end
end
```

You can edit this migration now. For example you could add some more
columns, with other datatypes:

```ruby
class CreateTweets < ActiveRecord::Migration[7.0]
  def change
    create_table :tweets do |t|
      t.string :status
      t.string :zombie
      t.integer :number_of_likes
      t.boolean :private

      t.timestamps
    end
  end
end
```

We could have specified those extra columns when generating the model like so:

```
rails generate model tweet status zombie number_of_likes:integer private:boolean
```


### How to build a first Table - run migration


Run the migration on the command line with `rails db:migrate`. This will run the appropriate `CREATE TABLE` statement in your database.

After that, the current schema of the database will be saved to
a file `db/schema.rb`. You never need to edit this file directly.

## Database Migrations

You just saw how you can build a database table and a model
file using `generate model`.  But why is the database table not
created directly?  Why generate a migration-file, and then run another command
to apply the migration-file to the database?

To answer this question we must look at the whole lifespan of
a web project.

During months and years of development the database schema will change just as much as
the code will change. And both changes belong together: if I push out
a code change to my fellow developers without the database changes,
they will not be able to use the code.

Database Migrations are a way to communicate database changes.

### One Migration

A "Migration" is a (small) change in the database schema. The change is
described in Ruby and saved to a file in the folder `db/migrations`.
The files are identified by a timestamp and a unique name, for example:

```
20231021100433_create_venues.rb
20231021100442_create_events.rb
20231021100501_add_video_link_to_events.rb
```

The first two of these migrations were generated by the model generator,
the last one by `rails generate migration AddVideoLinkToEvent`.

### A First Example

Here you see a first example of a migration file.  It was created
by the model generator.  When it is run, it  creates  a table from scratch.
The name of the table, and the names and data types of all the columns
are specified:

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

Use `rails db:migrate` on the commandline to apply this migration to the existing database.

### Rollback

You can think of the migration as a small step forward in changing the
database.  If you want, you can also go backward with `rails db:rollback`.
this will undo the last migration.

(Not always.  If you deleted a table with all it's data, then the rollback
will not bring the data back.)

During development on your local machine, you can try to formulate
the right migration, apply it, check if it wored, roll it back, change the
migration, apply it again... until you are happy with it.

But beware: once you have committed and pushed the migration, there is
no going back any more: as soon as other developers have started using
your migration, you cannot roll it back anymore.  You can only add more
migration files, with newer timestamps.

### a real world example:

The following output is from upgrading GitLab. GitLab
is written in Rails. Here we can see three migrations being applied to
the existing database.

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

## Data Types

You can specify the data type when running the generator.
`string` is the default Datatype, so these two lines give the same result:

```shell
rails generate model tweet status zombie likes:integer
rails generate model tweet:string status:status zombie:status likes:integer
```

Here are the most important ones to begin:

* `:string` and `:text`  are synonymous when using postgresql
* `:boolean` is for booleans  (use this, not a 0 and 1!)
* `:integer`, `:bigint`, `:float`, `:decimal`, `:numeric`  are number types
* `:datetime`, `:time`, `:date`, `:daterange`, `:interval` (the last two are postgresql specific)
* `:jsonb` is a postgres specific way to store json in an efficient way
* `:enum` is postgresql specific
* `:uuid` is postgresql specific, can be used for primary keys
* `:inet`, `:cidr`, `:macaddr` are postgresql specific types for network adresses
* `:binary`, `:blob`  for raw binary data


### Details for types

The generator will give you a good first draft of the migration, but sometimes
you will have to edit the migration to add details. For example: say you want to store
a monetary value you would use `:decimal` as the base datatype:

```shell
rails generate comic name price_in_euro:decimal
```
This is the resulting migration:

```ruby
class CreateComics < ActiveRecord::Migration[7.0]
  def change
    create_table :comics do |t|
      t.string :name
      t.decimal :price_in_euro

      t.timestamps
    end
  end
end
```

To specify that we want 15 digits in all, 2 digits after the comma,
we add `:precision` and `:scale`

```ruby
class CreateComics < ActiveRecord::Migration[7.0]
  def change
    create_table :comics do |t|
      t.string :name
      t.decimal :price_in_euro, precision: 15, scale: 2

      t.timestamps
    end
  end
end
```

Now the price is stored in the database in an optimal way to get
this format, and always retrieved in the right format:

```
# select * from comics;
 id | name | price_in_euro |        created_at         |        updated_at
----+------+---------------+---------------------------+---------------------------
  1 | Maus |        100.00 | 2023-10-30 11:45:54.45353 | 2023-10-30 11:45:54.45353
```


### Enums

Often we want to store a restricted set of possible values. Size could be small, medium or large,
status could be draft, published and archived, ... and so on.

There are several ways to store such a value in the database and use it in Rails.

1. Just use a string
2. Store an Integer in the Database, use `enum` in the Model to map this integer to a symbol
3. Create an Enum Type in the Database, use `enum` in the Model to map this enum to a symbol
4. Create a separate Table for the possible values, reference the table through a foreign key

This next example shows the first three options:

```shell
rails g model comic2 name category status:integer format:enum
```

For category (just a string) and status (integer in the database) we do
not need to change the migration. We can add a default value.
For the enum we need to add a definition to the migration, it needs
to be created before it is used:

```ruby
class CreateComics < ActiveRecord::Migration[7.0]
  def change
    create_enum :comic_format, ["book", "webcomic", "motion comic"]

    create_table :comics do |t|
      t.string :name
      t.string :category
      t.integer :status, default: 0, null: false
      t.enum :format, enum_type: :comic_format, default: "book", null: false

      t.timestamps
    end
  end
end
```

In the model file `app/model/comic.rb` we add the
mapping from the database to rails:

```ruby
class Comic < ApplicationRecord
  enum status: {
    draft: 0, published: 1, archived: 2
  }, _prefix: true

  enum format: {
    book: "book", webcomic: "webcomic", motion_comic: "motion comic"
  }, _prefix: true
end
```

Now we can work with the enums on the rails console:

```
railsconsole> c = Comic.new(name: 'Maus', status: :draft, format: :book)
=> #<Comic:0x00000001063d4fa8 id: nil, name: 'Maus', category: nil, status: "draft", format: "book", ...
irb(main):003> c.save
  TRANSACTION (0.3ms)  BEGIN
  Comic Create (3.9ms)  INSERT INTO "comics" ("name", "category", "status", "format", "created_at", "updated_at") VALUES ($1, $2, $3, $4, $5, $6) RETURNING "id"  [["name", nil], ["category", nil], ["status", 0], ["format", "book"], ...]
  TRANSACTION (0.8ms)  COMMIT
=> true
```

Notice how the status is converted to 0.

Trying to create an invalid status or format will raise a runtime error:

```
railsconsole> c = Comic.new(name: 'broken', status: :daft, format: :nook)
num.rb:157:in `assert_valid_value': 'daft' is not a valid status (ArgumentError)

          raise ArgumentError, "'#{value}' is not a valid #{name}"
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
railsconsole> c = Comic.new(name: 'broken', status: :draft, format: :nook)
enum.rb:157:in `assert_valid_value': 'nook' is not a valid format (ArgumentError)
```

We also get a few convenience methods for working with status and format:

```
railsconsole> c.status_published?
=> false
railsconsole> c.status_published!
  TRANSACTION (7.9ms)  BEGIN
  Comic Update (13.8ms)  UPDATE "comics" SET "status" = $1, "updated_at" = $2 WHERE "comics"."id" = $3  [["status", 1], ["updated_at", "2023-10-30 11:20:34.867427"], ["id", 1]]
  TRANSACTION (1.1ms)  COMMIT
=> true
```

## On Documentation

You could have learned all this and more from
the Rails Guides: [ActiveRecord Basics](https://guides.rubyonrails.org/active_record_basics.html), [Active Record Query Interface](https://guides.rubyonrails.org/active_record_querying.html) and .
Set a bookmark for the guides now! Use them as a reference from now on!

If you are offline now and again you should have the Ruby and Rails documentation available
locally on your computer. A handy tool for this on mac os x is
[Dash](https://kapeli.com/dash). This is what a Rails Guide looks like in Dash:

![Dash](images/dash-rails-guide.png)

### Further reading

- The Rails Guides give a good introduction to a subject area:
  - Rails Guide: [Active Record Migrations](https://guides.rubyonrails.org/active_record_migrations.html)
- Use the [Rails API](https://api.rubyonrails.org/) documentation to look up the details:
  - [add_column](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) lists all the possible data types for columns
  - [Rails Guide for Postgresql](https://guides.rubyonrails.org/active_record_postgresql.html) for postgres specific types like daterange, uuid or jsonb

