Jobs and Tasks in Rails
=======================

Your web application will need code that
is  run outside the HTTP Request-Response cycle.

By referring to this guide, you will be able to:

* Implement tasks that you can start from the commandline
* Implement jobs that are run automatically, but asyncronously

---------------------------------------------------------------------------

HTTP Request-Response Cycle
----------

A backend web frameworks normally works within the HTTP Request-Response Cyle.
In a Ruby on Rails app the flow is like this:

1. a HTTP Request comes in
2. the router deciphers the URL, decides which controller to call
3. the controller handles HTTP Parameters, Cookies, Session Data,
    1. loads models from the database
    2. decides which view to call
    3. sets headers for the HTTP response
    4. renders the view
4. a HTTP Response is sent

This should take less than 500ms from start to finish if
we want to achive a good response time for our users.

§

But some code we write is different: 
it might not fit within this
timeframe.  or it might not be triggered by a HTTP request.  

Some examples:

- convert uploaded media (images, movies) to different file formats or sizes
- send out e-mails
- delete data according to GDPR
- batch import data to your app


Tasks
--------

### What is a task?

In a Rails App **tasks** are small programs you - as the developer - can start on the command line. 

You have already used some predefined tasks:

```shell
$ rails db:migrate
$ rails test
```


You can get a list of all available tasks with `rails -T`.

When you deploy your app to a PAAS like heroku or dokku you can
start a task on the server using the command line:

```shell
$ dokku run rails db:migrate
$ heroku run rails db:migrate
```

A task can have access to  your application models, perform database queries, and so on.

### How do I generate a task?

Use `rails generate` to start writing a task.  For example I want to write
a task that loads user data from ActiveDirectory:

```ruby
$ rails generate task active_directory load
      create  lib/tasks/active_directory.rake
```

This will create a file `lib/tasks/active_directory.rake`

```ruby
namespace :active_directory do
  desc "add your description here"
  task load: :environment do
    # add your code here
  end

end
```

This task can be started by running `rails active_directory:load`.
Notice how the namespace defined in the first line and the taskname defined in the 
third line are combined when you call the task on the commandline.

The description defined with `desc`  is displayed when you run `rails -T`.

### How can I supply command line arguments?

The task to load data from ActiveDirectory needs arguments.

The Syntax for arguments is a bit strange: the
arguments need to be supplied in square brackets after the taskname without any spaces:

```shell
$ rails active_directory:load[username]
$ rails active_directory:load[username1,username2,username3]
```

§

You can give the arguments names and handle them as a hash, an array,
or as separate values.

```ruby
  task :load, [:a, :b, :c] => :environment do |task, args|
    puts "arguments as a hash: #{args.to_h}"
    puts "arguments as an array: #{args.to_a}"
    puts "arguments by position: #{args.a} and #{args.b} and #{args.c}"
  end
```

The code above can be run like so:

```shell
$ rails active_directory:load[1,2,3]
arguments as a hash: {:a=>"1", :b=>"2", :c=>"3"}
arguments as an array: ["1", "2", "3"]
arguments by position: 1 and 2 and 3
```

### How do I implement my task?

You can use all your knowledge of ruby, and all the code in your web
application.  To finish the taks we can use an already existing
`User` model and a `ActiveDirectoryLookup` service object.

```ruby
  task :load, [:username] => :environment do |task, args|
    ad = ActiveDirectoryLookup.new
    args.to_a.each do |username|
      result = ad.query(username)
      if result.nil?
        puts "Could not find user #{username} in ActiveDiretory"
      else
        u = User.find_or_create_with_ldap(result)
        puts "user #{username} is local user #{u}"
      end
    end
  end
```

### Other Task Runners

On **UNIX** Systems you can use `cron` to schedule tasks.

You can use **npm** as a task runner. 
Edit `package.json` and add your tasks under the key `scripts`:

```json
{
  "scripts": {
    "compress": "zip -r src.zip src/",
  }
}
```

run the task through `npm run compress`.  This works very well for starting command line scripts
like build or cleanup steps, or running tests.

See [the npm documentation](https://docs.npmjs.com/cli/v6/using-npm/scripts).

In **nest.js** [task scheduling](https://docs.nestjs.com/techniques/task-scheduling) is handled by node-cron.

In **Laravel** see [envoy](https://laraveldocs.com/docs/5.0/envoy).


Jobs
-------

### What is a job?

In a Rails App **jobs** are parts of your app that are not run within the
HTTP Request-Response cycle. They are also called **background jobs**.


### How do I generate a job?

Use `rails generate` to get started:

```shell
$ rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

As you can see a test is generated alongside the job itself.

Here's what a job looks like:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # Do something later
  end
end
```

### How can I start a job - later?

Somwhere in your rails app you can set the job up like this:

```ruby
GuestsCleanupJob.perform_later(g)
```

The job will be peformed asynchronously - outside the HTTP Request-Response cycle.
Calling `perform_later` will take up almost no time.

You can also define a time when the job should be run:

```ruby
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```


### How can I supply arguments?

You can define the argument list for `perform` any way you want.
The default is `*args` which captures all the arguments into an array `args`.

When calling `perform_later` you supply the arguments that will end up in `perform`.

You can only use primitive data types (Strings, Integers, Symbols, Date) as arguments for your job, but not Ruby Objects.

Why?  Because the Job is sent to a Queueing System for Storage. The data has to be serialized into a String, and deserialized again when it comes back to Rails.

The good news is: serialization and deserialization is automatically done for ActiveRecord models.
So you can use models as arguments.  But remember to implement de/serialization for any
other objects you want to use.


### How do I send E-Mail - later?

When sending E-Mail from Rails you can specify if you want
to do it synchronously or asynchronously:

```ruby
# If you want to send the email now use #deliver_now
UserMailer.welcome(@user).deliver_now

# If you want to send the email asynchronously through a Job use #deliver_later
UserMailer.welcome(@user).deliver_later
```

### How do I configure a queuing backend?

In development you can use the default queuing system called `async`.  
It's a poor fit for production since it drops pending jobs on restart.

For production you can chose another queuing backend, for example
[Sidekiq](https://github.com/mperham/sidekiq/wiki/Getting-Started) which
uses Redis to store the jobs.


Beyond Tasks and Jobs
----------

Using Jobs is a first step towards a more complex software architecture.
We have been building Web Apps from different parts that communicate through
APIs. Both REST APIs and GraphQL APIs are synchronous.

Jobs and asynchronous work open up a new way of thinking of our application: it
could be built from several parts that send each other messages, but don't wait
for a response. 

