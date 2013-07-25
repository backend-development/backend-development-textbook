Rails with Scaffold 
===================

We will build our first rails project but we will not really understand
everything - that comes later.

After finishing this guide you will

* have finished your first rails project
* know how to use the scaffold generator
* know about the main folders of a rails project: `config`, `db`, `app`
* have an overview of what model, view, controller (MVC) means in rails

-----------------------------------------------------------------------


Rails from the Outside In
-------------------------

Let's look at a fairly complex web application - the course
management system for a university. How would the code for this
app be organized, if it is written in ruby on rails?

The course management system surely deals with courses in some
way. 

Rails is organized along the distinction of model - view - controller (MVC).
In our exmple we would find:

* an entry in `conf/route.rb` that configures the mapping of  URLs and parameters to the controller
* several templates for courses in the folder `app/views/courses/` 
* a ruby class in the `apps/controllers` folder with the class name `CourseController`
* a ruby class in the `app/models` folder with the class name `Course`
* a relational database in the backend. this database contains a table `courses`

As a rails programmer you know about all these folders and files.  If you are
told that there is a problem in http://myapp.com/courses/5/edit you immediately
know to look in conf/routes.rb to find out exactly whic files are concerned,
but that the most likely canditates are

* app/models/course.rb
* app/controller/course_controller.b
* app/views/course/edit.html.erb

If you have not used a framework before this might feel very restrictive in the
beginning: you can't just make up filenames any way you want, there is a
**convention** for everything.  And you have to stick to the convention if you
want to profit from the framework.  But you will profit from this convention
every time you look at a new project - you'll instantly know your way around.


### Start a Rails Project

Before you can start your first rails project you have
to install ruby and the rails gem on your computer.  

A word of warning: Ruby and Rails will work on any Unix, including Mac OS. 
To use them on a windows system you need a lot more patience and troubleshooting
ability.  So if you are a windows user you might consider running
ruby and rails in a virtual (unix) machine (without GUI) instead. 

Make sure you are using a current ruby (>= 2.0) and rails (>= 4.0) before
you proceed:

``` sh
$ ruby -v
ruby 2.0
$ rails -v
Rails 4.0
```

Another word of warning: rails moves fast.  This was first written in the fall/winter
of 2012 for rails 3.2 and adapted in 1013 for rails 4.0. If you are reading this in the far future
(which in rails terms means: in late 1014 or later) you are probably
using ruby 2.2 or later, and rails 5 or later, and this text is **not** for you!


Before you start your rails project you have to decide on the name (and folder
name) of your application.  The name of application cannot easily be changed
afterwards!  In the following example we create an app called 'alljokes':

``` sh
rails new alljokes -T
```

The last step that was run automatically when creating a new rails project is `bundle install`.
This will try to look up gems on the internet - if you are not connected
to the internet you will be stuck here. You could try `bundle install --local` instead,
that might help if the gems are installed on your computer already.

### Rails Directory Structure

Rails will create a directory structure and about 40 files for you.
Let's start to look at a few of them:

* `Gemfile` - in this file you specify which libraries (gems) your project uses
* `app`
  * `model` - contains all the classes of models
  * `view` - contains a folder full of templates for every controller
  * `controller` - contains all the classes of controllers
* `config`
  * `database.yml` - database configuration
  * `routes.rb`  - configuration of routes
* `public` - the webspace. files in here are accessible without routing

With your code split up into so many different files it is really useful
to haven an editor that not only helps you edit a single file, but that
will also display the directories and files. For example vim with NERDtree
or submline or RubyMine:

![Screenshot of editor vim with NERDtree and rubymine](images/directory-structure-editors.png)

### Start the Webserver

Rails comes with a tiny webserver called `WEBrick`.  You start
it in your terminal window (and then you need another window to go on working)

``` sh 
$ rails server
```

Now you can point your browser at `http://localhost:3000/` to find the first
webpage of your app.  It's just a static page, you can find it in
`public/index.html`.


Make it a Git Repository
-------------

A new rails project is already prepared to be turned
into a git repository: there is a `.gitignore` file in the main 
folder.   (If you are using rubymine you could add `/.idea` to
your `.gitignore` - that's the directory where rubymine stores
it's configuration.  you probably want to keep that private to
each developer.

Create a new repository and commit in the current status:

``` sh 
$ git init .
Initialized empty Git repository in /Developer/alljokes/.git/
$ git add .

$ git commit -m 'empty rails project'
[master (root-commit) 2b2053c] empty rails project
 66 files changed, 1881 insertions(+)
 create mode 100644 .gitignore
 ..
 create mode 100644 vendor/assets/stylesheets/.gitkeep
 create mode 100644 vendor/plugins/.gitkeep
```

From now on you should `commit` your changes after every
finished step of programming.

Scaffold
-------------

A scaffold helps you build something.  In Rails a scaffold
helps you generate code according to the conventions.

In our application we want to store jokes.  Let's generate
the scaffold for that: We want a model called `joke` with
two attributes:  a (short) title and a (longer) fulltext.

When we call the scaffold generator on the commandline
we need to specify the name of the model, and the names (and types)
of the attributes.  short strings / varchars do not need a type at all.

``` sh
$ rails generate scaffold joke title fulltext:text 
invoke  active_record
create    db/migrate/20130725120328_create_jokes.rb
create    app/models/joke.rb
```

This will generate about 30 lines of output, and create 15 new files.
We will work through the files we need step by step:


### Migration

The first file we have to look at is stored in `db/migrate`.  The filename
will be different from the one shown above, because it contains a timestamp.

Inside the file you will find

``` ruby
class CreateJokes < ActiveRecord::Migration
  def change
    create_table :jokes do |t|
      t.string :title
      t.text :fulltext

      t.timestamps
    end
  end
end
```

This is ruby code to generate a database table. You can see the
two attrivbutes you specified when you called the generator.  There is
also a line `t.timestamps` that will add two more attributes to the
table: `created_at` and `updated_at`.  Rails handles these to values
automatically. 


You can run the migration (tell ruby to actually create the table) by
typing in `rake db:migrate` on the command line:


``` sh
$ rake db:migrate
==  CreateJokes: migrating ====================
-- create_table(:jokes)
   -> 0.0012s
==  CreateJokes: migrated (0.0013s) ===========
```

This actually created the table in a sqlite3 database called
`db/development.sqlite3`.  As a side effect it also dumped the current
database schema into `db/schema.rb` and created a second table
`schema_migrations`. This table is used to keep track of which migrations
have already been run.

### Use your app

After running the migration your app is ready to be used:
point your browser at `http://localhost:3030/jokes/` to start.

The scaffold generated four webpages that you can visit, to
list, show, create, edit and destroy jokes:

![webpages created by the scaffold](images/scaffold-with-arrows.png?viewbox=0;0;900;820)

* `/jokes/` is a list of all the jokes, with links to create, edit and destroy them
* `/jokes/1` shows a single joke, in this case the joke with id=1
* `/jokes/new` shows a form used to enter a new joke
* `/jokes/1/edit` shows a form to edit a joke, in this case the joke with id=1

### View

You can find the views that correspond to the webpages in `app/views/jokes`. Try to add a bit
of html to the following two views:

* `index.html.erb` is a list of all the jokes, with links to create, edit and destroy them
* `show.html.erb` shows a single joke

### Model

The model is stored in `app/models`.  Add the following validation:

``` ruby
class Joke < ActiveRecord::Base
  attr_accessible :fulltext, :title

  validates_presence_of :title
end
```

This tell the model not to accept jokes that have no title.

Now try to enter a new joke without a title, you should get a 
error message:

![Error message caused by unfullfilled validation](images/error-validation.png)

### Summary

We built a first rails app and ran it locally on our own machine.
You should now have an overview over the most important files
and a first impression of ruby code (used in controllers, models)
and embedded ruby (erb) used in the views.

Congratulations on your first step!


