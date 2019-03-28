Caching
=======================

What is even better than having a really fast web
server, framework, programming language that creates
your web page?  Not having to create and load the page at all
because it's already there in a cache.

After working through this guide:

* you will know that many different caches influence your web app:
   * HTTP caching
   * Fragment caching
   * ActiveRecord QueryCache
   * Caches inside the Database
* you will be able to configure rails for caching
* you will be able to measure if a change you made improved the performance of your rails app


DEMO: You can study [the demo](https://rails-caching-demo.herokuapp.com/) for the example described here
- if it's currently online.

---------------------------------------------------------------------------

## What is Caching

In computing we are faced with vastly different access speeds for different media:

* reading a megabyte of data from another host on the internet might take seconds 
* loading the smae data from a local ssd takes only 200 µs 
* reading the data from main memory takes 9 µs.

Given these numbers it makes sense to keep a local copy of data that
we  might use again soon.  Better to read it from ssd or memory the second
time we need it!

In general english usage a cache is [stuff hidden in a secret place](https://en.oxforddictionaries.com/definition/cache).  But in computing
a cache is "auxiliary memory from which high-speed retrieval is possible".

When you load a webpage into your browser there are many level
of caches influencing this process.  We will look at some of the caches
that we can influence as web developers.

## Measuring Performance

As we already discussed in [the chapter on the asset pipeline](asset_pipeline.html)
it is important to measure the performance of your app before you try to optimize anyhing.

In this chapter we will learn about new tools for measuring what happens on the server.

Let's start with a very general rule of thumb for performance:

We want the whole web page to load within a second. We expect to need about half of that (500ms) for loading extra assets like javascript files, css, images. We will set aside another 200ms for shipping data across the network, which leaves us with 300ms time to render out the first HTML document from our Rails App.


### rack-mini-profiler

This gem helps you analyze where your Rails App spends time.

![https://github.com/MiniProfiler/rack-mini-profiler](images/rack-mini-profiler.png)


[https://github.com/MiniProfiler/rack-mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)

See [RailsCast #368](http://railscasts.com/episodes/368-miniprofiler?view=asciicast) for a good introduction.

The Mini Profiler only measures the server side: the time spent in the rails app to generate
the webpage.  So we need to compare the numbers Mini Profiler gives us to the
300ms threshold defined above.

### Example App

We will use a portfolio site as an example app.  All the screenshots
above already show this example app.   You can study [the demo](https://rails-caching-demo.herokuapp.com/) 
on heroku, there all the caching is already implemented. 

## HTTP Caching

The web browser will cache content if sent the right HTTP Headers.
The Asset Pipeline handles that for images, css and javascript by default.
See [the chapter on the asset pipeline](asset_pipeline.html).

## Fragment Caching


### Configure Caching

Fragment Caching is deactivated by default in the development environment. 
You have to activate it if you want to try this out in development:

```
rails dev:cache
```

You have to decide on a cache store. For production the simplest
method when using just one web server is in-memory:

```
# config/environments/production.rb

   require 'active_support/core_ext/numeric/bytes'
   config.cache_store = :memory_store, { size: 64.megabytes }
```

To get a quick impression of what is saved to the cache
it is helpful to use the file_store in development:

```
# config/environments/development.rb
    # config.cache_store = :memory_store
    config.cache_store = :file_store, "#{Rails.root}/tmp/file_store"  
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
```


### Caching a View

If you look at the miniprofiler above, a first glance rendering
the project show view takes too long: 450ms.  We could dig
into the details, but let's try a simple approach first: cache
the whole view.


add this around the  whole project view:

```
<% cache @project do %>
...
<% end %>
```

The result is stunning: from 450ms down to 45ms:

![https://github.com/MiniProfiler/rack-mini-profiler](images/rack-mini-profiler-faster.png)


#### How caching works

So what happens here?  When the view is rendered for the first time
for a project, it will be rendered normally (and still take around 450ms).
In the log file you will see a message like this:

```
Write fragment views/projects/1679-20140722193808000000000/0db0955317bafa37cc34ffcb7567a874 (19.1ms)
```

This shows the key that is used for the fragment.  This key depends
on both the object we specified (here @project), and on the view fragment.
In this example '1679' is the id of @project, and '20140722193808000000000' is
the current value of its `updated_at` attribute. The last part
of the key is a hash of the view fragment inside the `cache` block.

So if either the object or the view changes, a new key will be generated
and thus the cache is expired.


When the view is rendered for the second time, you find the following message in the
log file:

```
Read fragment views/projects/1679-20140722193808000000000/0db0955317bafa37cc34ffcb7567a874 (1.9ms)
```

Here the cache is read out.  

#### Peeking into the cache

You can also read from the cache in the rails console:

```
irb(main):002:0> Rails.cache.read('views/projects/1679-20140722193808000000000/0db0955317bafa37cc34ffcb7567a874')
```

The result is a string with 14716 bytes of html (too long to show here).



When using file_store you can also find the cache in the directory you specified. 
A two level directory structure will be generated for the cache files, 
for example:

```
$ ls  tmp/file_store/*/*/*
tmp/file_store/5CD/A81/views%2Fprojects%2F2205-20170312162506000000000%2F0db0955317bafa37cc34ffcb7567a874
tmp/file_store/5D0/6A1/views%2Fprojects%2F2182-20170313205317000000000%2F0db0955317bafa37cc34ffcb7567a874
tmp/file_store/5D7/A81/views%2Fprojects%2F2208-20170321190926000000000%2F0db0955317bafa37cc34ffcb7567a874
tmp/file_store/5E6/091/views%2Fprojects%2F1679-20140722193808000000000%2F0db0955317bafa37cc34ffcb7567a874
```

#### Changing the model

Now let's check if the cache is really invalidated when the underlying model
changes.  Load the project "Origin" in your web browser: http://localhost:3000/projects/2015-origin

In the rails console you can find the corresponding model, and change an attribute:

```
project = Project.find_by_title('Origin')
project.description = project.description + " and some new information"
project.save
```

Now reload the browser to make sure that a new version of the page is rendered.
Reload again to check if the new version is cached.


### Caching a Partial

If you look at the homepage of [the demo](https://shrouded-dawn-29154.herokuapp.com/)
you can see that the list of project under "Bachelorprojekte" is different every time
you reload the page. There are 9 projects in all, but only 5 will be picked randomly
and will be displayed.

If we want to keep this feature caching the whole homepage will not work: once
the homepage is cached, a reload of the page will show the exact same page.
The same five projects will appear on the homepage indefinetly.

We could change our expectations for the random display: 
We could decide that the same 5 projects should be shown for a whole day, 
and only on the next day new projects should be picked.

This would work for our example app. a second approeach would be
to not cache the whole homepage, but only the display of an individual project. 
This means going down to the `projects/_project` partial, and caching that.

This second approach is useful not just for our "random projects". Think
of the "activity stream" on the facebook hompage: it will look differently
for each user, and each time the page is loaded.  But it consists of
smaller fragments which can be cached: the individual status message, or event,
or photo can be reused.

#### Implementation

When you add the code for caching to the `projects/_project` view
make sure that you specify the correct object.  If not, you might up
loading the same partial again and again:

![problem with fragement caching](images/caching-error.png)

If you implement it correctly each rendering of the partial should 
be faster now:

![successful fragement caching](images/compare-caching.png)

In Rails 5 you can speed up the rendering even more. 
If you look at the `fronts/show` view you can see that the project partial
is rendered through a collection:

```
<%= render :partial => "projects/project", :collection => @samples[i] %>
```

In Rails 5 you can add caching here:

```
<%= render :partial => "projects/project", :collection => @samples[i], :cached => true %>
```

Now instead of fetching each partial from the cache one by one
rails will do a multi-fetch, which is faster.  But our example app is written
in Rails 4, so this does not work yet.

See [Deshmane(2016)](http://blog.bigbinary.com/2016/03/09/rails-5-makes-partial-redering-from-cache-substantially-faster.html)

#### Side Effects

An unexpected side effect of caching the partial can be seen in the
[edition view](https://shrouded-dawn-29154.herokuapp.com/editions/bachelorprojekte-web-2015):
this view also uses the `projects/_project` partial, so it too will 
profit from the caching.

### Russian Doll Caching

In the previous step we implemented caching for the `projects/_project` partial,
which is also used in the `editions/show` view.  Now let's add caching to this
view also:


```
<% cache @edition do %>
...
<% end %>
```

This change will again speed up the display of the page:

![russian doll caching](images/russian.png)

But now we have  problem:  if we change one of the projects
inside this edition, the cache for the partial would be recreated.
But this never gets triggered, because the cache for the
whole edition is still valid:


```
project = Project.find_by_title('Origin')
project.title = 'Orange'
project.save
```

If you reload the page now, you can still see the project named "Origin", not
"Orange".

The problem here is a missing dependency: our cache entry only depends
on the edition, not on the projects contained in the edition.

We can declare the full dependency by supplying an array of objects to
the cache helper method:

```
<% cache [@edition,@edition.projects] do %>
...
<% end %>
```

If you reload the page now, you can see that a much longer cache key is
generated:

```
Write fragment views/editions/16-20160202125058000000000/projects/1622-20141216101932000000000 /projects/1658-20150601055523000000000/projects/1773-20170420014824000000000/projects/1835-20150604061050000000000/projects/1864-20150611174811000000000/projects/1872-20150603140238000000000/projects/1873-20150603084648000000000/projects/1879-20150606174629000000000/projects/2044-20161010124545000000000/e212725e51fc97160af625b6651e38b8
```

This key works for all changes in an edition:  

* changing an attribute of the **edition** will change the `updated_at` attribute also, and will change the key
* changing an attribute of one of the **projects** will change the corresponding `updated_at` attribute also, and will change the key
* adding a **new project** to the edition will make the key longer
* **removing a project** from the edition will make the key shorter 


In this example the title of one of the projects was changed:
You can see in rack-mini-profiler that only one of the
partials was recreated, all the other partials were loaded from cache.
The next time the same page was rendered the edition cache was reused.

![russian doll caching at work: changes when a project changes](images/russian-change.png)


### The limits of fragment caching

Caching is really helpful for pages that are accessed a lot.
In our example app this might be true for the homepage and
maybe the editions.   But there are hundreds of projects in the portfolio.
Each individual project page will only get very few hits.
Which means that chances are high that the page will not
already be in the cache when it is requested.

So caching cannot be the solution to all performance problems.
We need to take a closer look at the first render of a page
to find where we are wasting time.
To do this it makes sense to switch off caching in development:

```
# config/environments/development.rb

[...]
config.action_controller.perform_caching = false
[...]
```

## ActiveRecord and DB

Accessing the database takes a long time - compared to all
the computation that is done in ruby code itself.  So looking
at the Database, and the ORM we use to access the database, might
make sense for performance optimisation.


### Ignore this

If you  find `SHOW FULL FIELDS` queries in your log file or in rack-mini-profiler,
you can ignore them.  These
queries are used by activerecord to find out which attributes an
object has.  In production these will only occur when the first
object of a type is loaded, so you can savely ignore them.


### QueryCache

If you look into the log file `logs/development.log` you will
see all the SQL queries made to the database, and also some that
are not really sent to the database.

Here are some lines from a log file:

```
Started GET "/projects/2014-yokaisho" for ::1 at 2017-04-20 04:40:10 +0200
Processing by ProjectsController#show as HTML
  Parameters: {"id"=>"2014-yokaisho"}
...
  User Load (6.9ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 953 LIMIT 1
...
  CACHE (0.1ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 953 LIMIT 1  [["id", 953]]
...
  CACHE (0.0ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 953 LIMIT 1  [["id", 953]]
...
  CACHE (0.1ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 953 LIMIT 1  [["id", 953]]
```

What we can see here is that the Data for user 953 was loaded four times.
Somewhere in our rails app we call `User.find(953)` or similar ActiveRecord
methods four times.

But only the first time a SQL requests is really sent to the database. Loading
the data from the database took 6.9 ms here.

The next three times the same user was loaded, it was loaded from the
ActiveRecord QueryCache, which only took 0.1ms or less.

The default behaviour is that rails loads each model only once for each
HTTP request. For the next HTTP request the QueryCache is cleard.

If you ever run into problems with the QueryCache, you can always
reload a model explicitly:


```
user = User.find(953)
# will do SQL request
user = User.find(953)
# will use the query cache
user.reload
# bust the query cache, do a real SQL query
``` 

### using indexes in the database

When we query the database by `id` we will get a rapid response:
the primary key is always accessed through an index.

But in this app the main way of identifying a resource is
through a "friendly url".  For example the project show action
is not accessed through the conventional route

```
/projects/1679
```

but through

```
/projects/2014-anton-eine-multimediale-inszenierung
```

In the profiler we can see that this translates to the SQL query

```
SELECT * FROM projects WHERE slug='2014-anton-eine-multimediale-inszenierung' 
```

There should be an index on columns `slug`!

We can check if this is the case in the database console:

```
mysql> DESCRIBE SELECT * FROM projects WHERE slug='2014-anton-eine-multimediale-inszenierung'
    -> ;
+----+-------------+----------+------------+-------+------------------------+------------------------+---------+-------+------+----------+-------+
| id | select_type | table    | partitions | type  | possible_keys          | key                    | key_len | ref   | rows | filtered | Extra |
+----+-------------+----------+------------+-------+------------------------+------------------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | projects | NULL       | const | index_projects_on_slug | index_projects_on_slug | 768     | const |    1 |   100.00 | NULL  |
+----+-------------+----------+------------+-------+------------------------+------------------------+---------+-------+------+----------+-------+
1 row in set, 1 warning (0,12 sec)
```

Yes, there is an index that is used for this query.  Contrast this with the output
of `DESCRIBE` when there is no index:

```

mysql> DESCRIBE SELECT * FROM projects WHERE publicationdate='2014-07-22';
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | projects | NULL       | ALL  | NULL          | NULL | NULL    | NULL |  695 |    10.00 | Using where |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
1 row in set, 1 warning (0,12 sec)
```


### n+1 queries

When analysing the SQL queries a rails project generates
you will often find this situation: you have a 1:n relationship,
for example: a project has many users.  When displaying
the project with all of its users you see n+1 queries.
In our example app this happens:

```
SELECT * FROM `projects` WHERE `slug` = '2014-yokaisho' ORDER BY `projects`.`id` ASC LIMIT 1
SELECT * FROM `projects_roles_users` WHERE `project_id` IN (1622)
SELECT * FROM `users` WHERE `id` = 1033 LIMIT 1
SELECT * FROM `users` WHERE `id` = 1018 LIMIT 1
SELECT * FROM `users` WHERE `id` = 901 LIMIT 1
SELECT * FROM `users` WHERE `id` = 938 LIMIT 1
SELECT * FROM `users` WHERE `id` = 945 LIMIT 1
SELECT * FROM `users` WHERE `id` = 977 LIMIT 1
SELECT * FROM `users` WHERE `id` = 953 LIMIT 1
SELECT * FROM `users` WHERE `id` = 652 LIMIT 1
SELECT * FROM `users` WHERE `id` = 940 LIMIT 1
```

Here 9 users belong to the project. They are loaded using 9 requests.
This is inefficient!  If we were coding SQL by hand, 
we could get the same data using one query with a join.

We can use rack-mini-profiler to find the code line that generated
the request:

![finding the source code for a sql request](images/sql-project.png)


In this example, the ActiveRecord method that generate
the first request is in project_controller.rb, line 26

```
@project = Project.friendly.find(params[:id])
```

Later, in the view and partials, the relationships from
@project to users is accessed.

To get ActiveRecord to automatically load **all the users** at once
we can change this one line to use the 'includes' method:

```
@project = Project.includes(:users).friendly.find(params[:id])
```

After this change we find a lot less SQL requests:

```
SELECT * FROM `projects` WHERE `slug` = '2014-yokaisho' ORDER BY `projects`.`id` ASC LIMIT 1
SELECT * FROM `projects_roles_users` WHERE `project_id` IN (1622)
SELECT * FROM `users` WHERE `id` IN (1033, 1018, 901, 938, 945, 977, 953, 652, 940)
```

This makes a measurable difference:

![compare render times with and withoud include](images/sql-include.png)

In this example there are many more models that belong to a project.
If we include them all, we end up with a sizable reduction in SQL queries:

```
@project = Project.includes(:users, :roles, :assets, :urls, :tags).friendly.find(params[:id])
```


![compare render times with many includes](images/sql-include-more.png)


### view

We still have many more SQL queries that are created
for the `collaborators/_show` partial. 

The collaborator partial shows information
about one team member: the thumbnail, the name, their degree program(s)
and the role(s) they had in the project.

![collaborator partial](images/collaborator.png)

The information about the degree programs is found in 2 different tables:

* studycourses
* agegroups_studycourses_departments_users


To display "MMT Bachelor 2010, MMT Master 2014"
for Mr. Huber the helper method `print_studycourses` is used. We can try out this
helper method in the rails console:

```
> user = User.find(901)
  User Load (0.5ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 901 LIMIT 1
> ApplicationController.helpers.print_studycourses(user)
  Enrollment Load (0.5ms)  SELECT `agegroups_studycourses_departments_users`.* FROM `agegroups_studycourses_departments_users` WHERE `agegroups_studycourses_departments_users`.`user_id` = 901
  Studycourse Load (0.3ms)  SELECT  `studycourses`.* FROM `studycourses` WHERE `studycourses`.`id` = 3 LIMIT 1
  Agegroup Load (0.4ms)  SELECT  `agegroups`.* FROM `agegroups` WHERE `agegroups`.`id` = 3 LIMIT 1
  Studycourse Load (0.4ms)  SELECT  `studycourses`.* FROM `studycourses` WHERE `studycourses`.`id` = 5 LIMIT 1
  Agegroup Load (0.4ms)  SELECT  `agegroups`.* FROM `agegroups` WHERE `agegroups`.`id` = 19 LIMIT 1
```

Here information from three database tables is combined.

#### createing a database view

In the database console we can build a simple select statement with two
joins to get the same information:

```
mysql> SELECT user_id, concat(studycourses.name, ' ', year) AS name 
FROM agegroups_studycourses_departments_users x 
LEFT JOIN studycourses ON (x.studycourse_id=studycourses.id) 
LEFT JOIN agegroups ON (x.agegroup_id=agegroups.id) 
WHERE user_id=901;
+---------+-------------------+
| user_id | name              |
+---------+-------------------+
|     901 | MMT Bachelor 2010 |
|     901 | MMT Master 2014   |
+---------+-------------------+
2 rows in set (0,01 sec)
```

We can create a view in the database that contains this information:

```
mysql> CREATE VIEW degree_programs AS 
SELECT user_id, concat(studycourses.name, ' ', year) AS name 
FROM agegroups_studycourses_departments_users x 
LEFT JOIN studycourses ON (x.studycourse_id=studycourses.id) 
LEFT JOIN agegroups ON (x.agegroup_id=agegroups.id);
Query OK, 0 rows affected (0,06 sec)
```

This view can now be used like any other table in the database:

```
mysql> SELECT * from degree_programs WHERE user_id=901 ;
+---------+-------------------+
| user_id | name              |
+---------+-------------------+
|     901 | MMT Bachelor 2010 |
|     901 | MMT Master 2014   |
+---------+-------------------+
2 rows in set (0,00 sec)
```


#### model and relationships for the view

In Rails we can define a model for this view:

```
app/models/degree_program.rb
class DegreeProgram < ActiveRecord::Base
  belongs_to :user

  def to_s
    name
  end
end
```

And add a relationship from user:

```
class User < ActiveRecord::Base
...
  has_many :degree_programs  
```

back in the rails console we can now use this new model:

```
> user = User.find(901)
  User Load (0.5ms)  SELECT  `users`.* FROM `users` WHERE `users`.`id` = 901 LIMIT 1
> user.degree_programs.join(', ')
  DegreeProgram Load (0.6ms)  SELECT `degree_programs`.* FROM `degree_programs` WHERE `degree_programs`.`user_id` = 901
=> "MMT Bachelor 2010, MMT Master 2014"
```

And finally we can refactor the helper method print_studycourses

```
  def print_studycourses(student)
    student.degree_programs.join(', ')
  end
```

This reduces the number of SQL statements to one per collaborator partial:

![view](images/view.png)

#### create view in production


To deploy the view to production, you need to create it with a migration:

```
class CreateViewDegreeProgram < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW degree_programs AS
      SELECT user_id, concat(studycourses.name, ' ', year) AS name
      FROM agegroups_studycourses_departments_users x
      LEFT JOIN studycourses ON (x.studycourse_id=studycourses.id)
      LEFT JOIN agegroups ON (x.agegroup_id=agegroups.id)
    SQL
  end
  def down
    execute 'DROP VIEW degree_programs'
  end  
end
```

#### uses and limitations of view

In this case the view might be a first step towards refactoring
the database.  We just have too many tables in the database that
are not really needed.

We can rewrite the rails app step by step to use only the new view,
and not the database tables it is supposed to replace. after we
have changed all the rails code, we can drop the view, and create
a table with the same data instead.  Then we can drop the original tables
and are finished with the database refactoring.


In other cases you might use a view permanently: If you need both
the underlying, more complex data, and the simplified data in the view.
Reports with aggregated data, top 10 lists, queries that use
complex database expressions, or tables with a reduced set
of attributes would be good examples for using a view.

For data that is accessed a lot, but changes very seldom, you can
us a **materialized view**.  In a normal view each access to the view
triggers the underlying sql requests.  In a materialized view the
data is copied over to the view once. This needs more memory, but gives
faster access.


### final thoughts


If we add a relationship from projects to degree_program (actually: three `has_many through:` steps to get from projects to collaborators,
and from collaborators to users, and from users to degree_programs), we can also include degree_programs in our
includes statement when loading the project:

```
@project = Project.includes(:users, :roles, :assets, :urls, :tags, :degree_programs).friendly.find(params[:id])
```



This way we end up with only very few sql queries, and a big performance improvement:

![final state of the app](images/before-after.png)

ActiveRecord was a big help when writing this app. But it cannot find
the best solution for every situation. As a developer you have to keep
an eye on your ORM, and check now and again if the SQL queries that the
ORM creates make sense and are efficient.


See Also
--------

* [Rails Guide: Caching](https://guides.rubyonrails.org/caching_with_rails.html)
* [Rails Guide: Active Record Query Interface. N+1 problems](https://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations)
* [Berkopec(2015): Speed Up Your Rails App by 66% - The Complete Guide to Rails Caching](https://www.speedshop.co/2015/07/15/the-complete-guide-to-rails-caching.html)
* [bullet gem for finding n+1 problems](https://github.com/flyerhzm/bullet#readme)
* [Using database views for performance wins in Rails](https://content.pivotal.io/blog/using-database-views-for-performance-wins-in-rails)
* [materialized views in mysql](https://www.fromdual.ch/mysql-materialized-views)
* [materialized view in postgres](https://www.postgresql.org/docs/9.3/static/rules-materializedviews.html)
* [DHH(2012): How key-based cache expiration works](https://signalvnoise.com/posts/3113-how-key-based-cache-expiration-works)
