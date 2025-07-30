Rails 8 Demo - From Hello World to IPO
==========================

There is a Demo Video for Ruby on Rails on
https://rubyonrails.org/
David Heinemeier Hansson shows off a lot of Rails
in a very short time.  This page is a slower version
of the video with a focus on the basic concepts of Rails.

After reading this you should:

* know and recongnize some basic concepts of Rails
* have an overview of the capabilities of Rails
* know that you will be using the command line and a code editor for developing with Rails
* be ready to build your own first Rails application

-------------------------------------------------------------------------------


This is a recreation of DHHs video introduction to rails, only a bit slower and with a focus on the concepts behind rails.  It will give you a tour of the whole rails stack and a rough overview of the concepts. We will go deeper into the concepts later in the course.

This Video starts at the moment where ruby - the programming language and rails - the framework are already installed on a computer, and we have a terminal and a code editor running.

## rails new

the first command typed into the terminal is

```bash
rails new blog
```

rails is the program we are starting, we are giving it the command “new”, and supplying a name for the new project “blog”.  the structure is:  rails new <projectname>

The program gives a lot of output. you should be able to recognize that:

* folders and files are created
* a git repository is initialized
* a file .gitignore is created
* the program `bundle` is run

## rails generate scaffold

after a short look at the directory structure generated, DHH
immediately starts a second command in the terminal:

```bash
rails generate scaffold post title:string body:text
```

All the command starting with `rails generate` help with creating
code files. `rails generate scaffold` generates all the
files needed for a database table and a web interface
with CRUD-operations (create, read, update, delete) for that table.

When running the command it again gives a lot of output:

![](/images/rails-scaffold.png)

Have a look at the files created:

* db/migrate/... is for making a change in the database, a so called "migration"
* app/models/... is for the models, the part of the code most closely concerned with the database
* test/* is concerend with automatic tests
* routes are concerned with deciding which code is run for which URL
* app/controller/... is for controllers, the part of the code that handles HTTP requests and decides how to respond
* app/views/*.html.erb are the views. these are the different HTML-documents that might be returned in a HTTP response
* app/helpers/* is for code that does not belong any place else, and might be useful in a view or a controller
* app/views/*.json.jbuilder are used to return JSON in a HTTP response

## running the migration

next DHH rund the command

```bash
rails db:migrate
```

in the terminal. this is the output:

![](images/rails-db-migrate.png)

You can see that it reports that it created a table called "posts".
The sqlite3 database was set up automatically when we ran `rails new`.

## the posts controller

next DHH shows the file app/controllers/posts_controller.rb
and does through the seven methods defined there. The methods
are also called "actions":

* index 
* show
* new
* edit
* create
* update
* destroy 

DHH points out that everything is served in two flavors: HTML and JSON.
For example the create-action is defined like this:

```ruby
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end
```


If you read the english words in there you can see that
the response can have two formats: either it is html  or json.
HTML is for direct display in a web browser while the JSON is
part of an API that rails automatically offers.

## parameters for the controller
And as you can see here, we’re also setting up
a new post for some of those actions
that require that, we’re gonna find it straight off an ID
passed in through the URL, and the post parameters
are the ones we’re using when we’re creating
and updating the application.

## the model

If we jump into the post model,
you’ll see there’s actually nothing here.
Everything in the post model
is made available through introspection.

So, a new post model will look at the schema for that table,
and it will know that there is a title and there is a body,
and we can access that title
in that body directly through this post object.
And as it descends from application record,
we can run everything from updates and destroys,
and what have you.
This is also where we’re gonna put our specific logic
that’s particular to this application
beyond just the management of attributes.

## the views

And then finally,
we have the views that are being generated.
If we hop in here and have a look at the index view,
you can see this is where we will list all the posts
that are in the system.

And Rails uses ERB, which is essentially embedded Ruby.
So, you mix HTML with Ruby in line,
and you can split out more complicated functions
into helper methods.

But otherwise, this is the clearest cut setup in Rails
that is the default for integrating HTML and Ruby.

## starting the server

Now if we hop over
and start up our development server,
you do that with just bin/dev.  (no: rails server)

If we were running a Rails application
that also had auxiliary watcher processes
such as one for ES build or for Tailwind,
bin dev would start those as well.

But this version of our Rails blog,
it’s just going to be built with all vanilla, no build
set up so we only need to start the Puma, Ruby web server,
and we can hop over into the browser and see here.

## in the browser

This is the thing you’re gonna see
when you start up a new Rails application,
it’ll tell you which version you’re on,
both for the Ruby version, the Rails version,
and the Rack version
that’s running on localhost:3000 S by default.

## the scaffold in the browser

But if we do slash posts here,
you’ll see the scaffold interface that we generated.
Now, this is the index action,
the one we just looked at in the view
and from the controller.

But if we click the New, you see here we have a form
for creating the new post with its title and its body.
It’s quite basic, to put it mildly right now,
but all the actions are mapped out.

This scaffold interface
is not meant for shipping into production,
it is meant to showing you how to build a Rails application
with the basics, and then you make it look pretty,
you make it look nice.

## API

Let me show you real (chuckling) quick here,
if you do a /post.json,
you’re gonna get that automatic API as well,
as I showed you in the controller,
there are two different paths,
you have HTML, and you have JSON.

You could also have added XML in there or another path,
but by default, you just get these two different variants,
the HTML and the JSON variant.

## Adding CSS

Now if we hop back into
our editor here, I can add a little bit of styling
to make this look slightly nicer than the very basic layout
that you get with the scaffold.
By default, I like to use simpleCSS.

It is simply a individual file that’s being included,
I don’t have to compile anything here,
I’m just referencing it straight off their CDN.

And if we save that and reload,
you can see it just looks a little nicer.

Now, Rails has a bunch of different ways you can do the CSS,
there’s also a path where you can use Tailwind.
Lots of people like that for good reason,
and there are a bunch of different options,
all the major CSS frameworks are available,
but by default, we ship with a no build, as I said,
intention and simple CSS just makes things look prettier
without having to adorn anything with classes,
or what have you.

## exception and web console

Now, lemme show you one of the first features here.
If we do raise exception inside the index action,
you will see that Rails provides some really nice interface
for dealing with that exception,
seeing exactly where it happened.

If I’m reloading here, you can see the line,
it was raised on the source code that’s around it,
you can see a full trace.

And down here, we even have a console!
So, you can interact with the instance variables
that have been set for this index action,
here’s just at posts that’s been made available.

And you can help diagnose whatever issue
that it is that you have!

## rails console and activerecord

But let’s remove that again,
and then let’s look at the console from another angle.

Now, you can get the console
as I just showed you when an exception is raised,
but you can also get the console
if you just run rails console!

Now you have access to your entire domain model.
So if we find the first post that we created, we can update
that post straight here from the console,
if we hop back, you see, title is now changed from CLI.

This is exceptionally helpful for interacting
with your domain model, updating things on the fly,
and as you will see later, updating things
even once you’ve deployed this to production!

## action_text

Now, let’s install something else here,
let’s install action_text,
that is one of the frameworks that’s part of Rails,
but it’s not set up by default,
but you can set it up by running rails action_text:install,
that’s going to give you a WYSIWYG editor
that’s currently powered by Trix!
The open source, what you see
is what you get editor made in JavaScript!

And it also sets up active storage!
Active storage is a way to deal with attachments
and other files in your Rails application.

When you run it through action_text:install,
it’ll automatically set up
those active storage tables that we need,
there is one for the blob,
and then we have one for text here.

We run migrations to set that up again,
and now that we’ve run action_text:install,
it also added a couple of gems,
so we need to restart our development server.
I do that just by exiting out
and then just running the server again!

If we then hop into our
post model `/app/models/post.rb`, we can declare that that post model
has rich text body.


```ruby
class Post < ApplicationRecord
    has_rich_text :body
end
```

We’re gonna convert the plain text body
that we had just a second ago to a rich text body
that is accessible through the WYSIWYG editor,
and that accepts
those active storage attachments and uploads.


But before we can do that,
let’s change the text area we had in the form here
`/app/views/posts/_form.html.erb`
for our new post to be a rich text area.

```ruby
  <div>
    <%= form.label :body, style: "display: block" %>
    <%= form.rich_text_area :body %>
  </div>
```

That’s basically all you have to change,
and let’s save that and hop back into creating a new post.

As you can see here, there is now a full WYSIWYG interface
for creating the body.

It comes with a default set of styles for the toolbar,
you can change those,
those styles are generated straight into your application,
so you can make it look nice for yourself.

Let’s give some bold and italic text here, you see,
that was all that was needed.

But I think what’s even nicer to look at here
is if we do an upload and we add a file,
you will see that that file gets added with a preview
directly to the WYSIWYG editor.
And if we save that
and we update the post, it is added to the post itself.

And that then went through
the whole process of doing a direct upload of the file
when we dropped it into the editor,
that uploads it straight to active text
or active storage.

And then, we have access to that, and rendering it directly
from whatever storage backend active storage is using.
In this example, we’re just storing on disk,
but you could be storing your active storage in S3
or another object storage.

## javascript

Now, let’s add a bit of custom JavaScript.
Rails by default ships with Hotwire!

`/config/importmap.rb`

Hotwire gives you Turbo,
which is a way of accelerating page changes
and updates is that your application
will feel as fast and as smooth as a single page application
without you basically having to write
any JavaScript at all.

And then, there’s the stimulus framework
for creating that additional functionality
that you might need in a really simple way.

You can have a look at hotwire.dev to see more about that,
but what we’re gonna add here is
a little piece of JavaScript
to just add some additional functionality,
pulling something in from NPM!

So, we can do that using the import map pin command.

```bash
bin/importmap pin local-time`
```

And as you see, now that I hop back into
our config import map,
we’ve added the local text pin at the bottom, version 302.

It pulled that straight off NPN,
it downloaded that as a vendor dependency
that we can check into our version control system.

And now, we don’t have any runtime dependency whatsoever
on NPN, or anything else like that.

You don’t need anything
beyond what Rails ship you with already
because Rails 8 is all no build by default!

That means there’s not a transpiler,
that means there’s not a bundler,
these files are shipped directly to the browser over HTTP2,
so it’s nice and fast.

And the import map is what allows us to refer to these files
by their logical names while still doing
far future digesting, so that they load really quick,
and such that they’re easily compatible with CDNs
and all that good stuff.

But now that we’ve added that,
let’s have a look at our application JS file.

`/app/javascript/application.js`

That’s the default setup that you have
that the scaffold is going to use.
And as you can see, we’re using turbo-rails,
we’re including all the stimulus controllers,
if we have any.

We’re including trix and action text to give the WYSIWYG,
and now we’re gonna add that local text package as well.
And we’re gonna start local time here.

And in the local time, we’re gonna use it,
and we’re gonna use it for adding
the updated at timestamp here.

`/app/views/posts/_post.html.erb`

And as you can see here, we’re just adding a time tag
that’s just a vanilla HTML tag that has a data local time,
that’s what activates the local time JavaScript set up.

```ruby
  <p>
    <strong>Update at:</strong>
    <%= time_tag post.updated_at, "data-local": "time", "data-format": "%B %e, %Y %l:%M%P" %>
  </p>
```

And we will give it a format
for what it should do with that UTC timestamp,
and turning it into a local time that we can have a look at.

So if I reload here, you see it is November 13th,
by the time of my recording at 3:28 PM
in my local time zone, but actually underneath, the time tag
is gonna be in UTC.

That means we can cache this, and anyone around the world
will still get the time displayed in their local time.
Just a nice feature.

But really, what’s unique here for Rails
is the fact that we’re using no build by default!

So if I go over here in the inspector
and look at the JavaScript files that are included,
you can see we have the application js file
with a little digest stamp on there.

![](images/network-inspector.png)

If we change anything that application js file,
the digest is going to change,
and the browser will redownload just that part!

But everything else, turbo and stimulus,
if they’re not changing, we’re not downloading that.

That is why no build
is such an efficient way of dealing with caching.

But we can also have a look at a specific file,
you’ll see it matches exactly what we have back there.
That’s not a development setup!
That is what we’re shipping in production.
There is no minification, there’s no transpilation,
there’s none of that nonsense
because you just don’t need it.

We’re Gzipping or Brotliing this stuff
so that it transports really quickly,
but we’re allowing you
to view source on an entire application.

If you look at something like hey.com,
you’ll see this technique in use on a major application,
and you can view all of the JavaScript that we use
to build that application, and that’s the default for Rails.

Now again, if you don’t want any of this stuff,
there is a way using `jsbundler-rails`
to set things up in a more traditional way
using ES build and what have you.

But this is a wonderful way of developing
modern web applications.

## comments

Alright! Now let’s add some comments to our blogging system!

```bash
rails generate resource comment post:references content:text
```

![](images/generate-comments.png)

And I’m gonna use a different generator here,
I’m gonna use a resource generator
that is a little lighter
than the one we were using for scaffold
that doesn’t generate a bunch of views,
and doesn’t generate all sorts of actions
in the controller by default, but it does generate
the new model that we need,
the comment model, it generates a migration for that,
create comments, and it generates
just some empty placeholders for the comments controller
and for the view action.


So, let’s run the migration for that,
that sets up the comments table.

```bash
rails db:migrate
```


You can see here (in `/db/schema.rb`) the schema that we’ve now built up.

We’ve added a number of tables for action text
and action storage.
And then, we have added a comments table.

That’s as you see here.
As we had it in the migration
where we were just referencing the post as a foreign key,
and then we had the content as text.

And then, Rails by default also adds two timestamps
that it keeps track of by itself, created ad and updated ad.

And below that, you had the post that we added originally.
Alright, if we hop into that comments controller (`/app/controllers/comments_controller.rb`),
it was empty.


As you can see there, I’m gonna pay something in
that actually makes this stuff work!

```ruby
class CommentsController < ApplicationController
    before_action :set_post
    
    def create
        @post.comments.create! params.expect(comment: [ :content ])
        redirect_to @post
    end
    
    private
    
    def set_post
        @post = Post.find(params[:post_id])
    end
end
```

You’ll see one principle of the controller setup we have
is that we have these callbacks.

Before action, we’re gonna set posts.

So before all the actions, we’re going to reflect
the fact that this is a **nested resource**.

The comments is something that belongs to a post,
and we will pull out the post ID from the params,
that’s what’s being parsed in as part of the URL,
and we will fetch that post,
and now we will create the comments
associated with that post based on the parameters
that are expected as comment content.

And then after it’s created,
we will redirect back to the post!

So,
let’s actually also (chuckling) create
the other direction of this association.



```ruby
# /app/model/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
end

# /app/model/post.rb
class Post < ApplicationRecord
    has_rich_text :body
    has_many :comments, dependent: :destroy
end
```

You saw a comment belongs to a post,
but then we’re also gonna make the post has many comments.

Now, we have a bidirectional association
that we can work with in both ways.

Now, we’re also gonna add a number of partials here.
This is the templating system,
basically, a sub-routine that you can refer to.
There’s gonna be three of them.
There’s gonna be the comments
that includes the entire comment section.
We’re gonna reference that
in our post show in just a second.
And within that, we’re gonna refer to
another partial for an individual comment,
and another partial again for the new setup.
So, let’s paste some of that in here.
You can see this is for the entire collection,
it just has an H2 for the comments,
and we render the post comments.
This again uses Rails’ convention
over configuration approach.
It’ll automatically know that the comment model
should map to view slash comment slash comment,
so it can look up the right partial file to use.
And then below that, we have the form
that we’re referencing with the comments new.
So, let’s hop in and paste in the individual comment.
As you can see here, we just give it a div,
that has a dom ID so that we can reference it.
We are pacing in the comment,
and we’re using that same time tag as we were using
with the post, but this time, we are going to use time ago,
so we get that nice two minutes ago
on when something went posted
rather than a local time spelled out with AMPM set up.
And then finally, let’s paste in the form
that we’re gonna use.
That form is going off a model,
the new comment, but it’s nested underneath the post,
is that we automatically can deduce
which URL that we should post this new form to.
And your comment is just gonna be a text area for content.
We could have made this a rich text field as well,
but let’s keep things simple and just keep it in plain text!
Now that we have that up, we can hop in
and hook it all up into the show action for the posts!
That’s gonna reference that common slot comments,
that includes both the comments and the new form!
Alright, let’s save that and hop back into our browser.
Oop! I made a mistake here!
When we generated the resource,
it added a route for the new comments,
but that route was not nested by default.
We actually need to go into our routes.rb,
and then see here,
that resource we added needs to be nested.
When it is nested, we get the fact
that it’s gonna be slash post slash one slash comments,
and we have the association is set up nicely.
Now, let’s reload!
Now, it works, we have our comments field underneath,
we can add the first comment.
And as you can see here,
this is my first comment a second ago
that was the local time doing its time ago conversion.
Now, let’s set things up to be dynamic,
such that when we add a new comment
to one of these, it’s going to update the other as well.
This is how we use web sockets in Rails using action cable,
one of the frameworks that we have to create updates
that are distributed automatically
without folks having to reload their browser.
So if we scroll down to the bottom here, we are ready.
The first thing we’re gonna do, we’re gonna add
a turbo stream from post
to the show files to the show template.
That’s gonna set up the web socket connection
and subscribe us to a channel named after
that particular post that’s pasted in.
And if we hop into our comment,
we can set up a broadcast_to
for that post.
The broadcast to will broadcast all updates
made to that comment, whether a new comment is updated
or an existing comment is changed in some way
or even one deleted,
and send it back out to a channel
on action cable named after the post association
that this comment belongs to!
And that is basically it.
Now if I go over here
and I add a comment to one of these,
you see the comment was added on the left immediately
at the same time.
That’s all web sockets automatically happening
through action cable.
And we can do it of course the other way as well.
Alright, that is very neat.
Now, let’s go to production!
Because of course, you’re not just here
to create a Hello World app that runs on your own machine,
you want to get this out into the world!
And Rails8 and forward ships with Kamal,
a simple tool for deploying your web application anywhere.
And there’s a default configuration file
in config/deploy.yml that we can use,
it’s prefilled a little bit,
it has the service name of the name of reaction,
but we need to rename, for example, your user,
the name of the image to go
to my name of where I store this on Docker Hub.
You can see we changed that down in the registry as well
and the name of the container image.
Now, I’m gonna deploy this on my own little hoppy server.
And that hoppy server is currently wiped.
It is completely clean, and Ubuntu 2404
setup that has nothing on it already,
this is part of the magic of Kamal,
you can spin up a new VM anywhere in the cloud
or use your own hardware and point Kamal straight to it,
and you’ll be going in no time!
So, this server exists
on this address, demo@exitsoftware.io
And I will then fill out the host as a C name
to that machine.
But we’re using Alpha here,
if I had deployed another application called Bravo
to the same server, Kamal would set it up,
so it’s like I host two applications
or any number of applications on that same server!
Now, we will also need to have a look at the secrets here,
that is in dockyml/secrets,
because the register that I’m using,
that is Docker Hub, needs of course a password,
it is using my username but also needs a password.
And you can pull that password
from a bunch of different places,
you can pull it from a credential store like one password,
you can pull it straight out of GitHub command,
as you can see here with the GitHub token above,
or you can pull things out of ENV.
I’m pulling it out of ENV with my Kamal registry password
that I’ve already set up on my personal bash.
And then, the Rails master key
that does the decoding of any credentials
we’ve set for Rails,
it’s just using a cat straight out of config master key.
You’ll need to change that
if you’re working with other people of course,
because you don’t wanna check
that master key into your Git repository,
you’re gonna wanna pull that out of one password
when you go for real.
But this is all we basically need,
we are now ready to check in the entire project into Git!
Kamal uses Git for keeping track of versions,
and we can now run Kamal setup!
And that’ll connect to that remote server,
and it’ll install Docker if it’s missing,
it’ll build the Docker file
or the Docker container off the Docker file
that Rails ship with by default,
there’s nothing you need to set up there.
And it will deploy it, push it out,
do it in a red green deployment
or blue green deployment such that there is no gap
in that deployment as you set things up.
And as you can see here, I sped things up a little bit,
but it was about 80 seconds on my Linux machine
from a cold boot to do that.
Now, we can hop back in here and go to alphaexitsoftware.io
and see, whoops!
There was a 404 here!
That’s because if we go back to our route (chuckling) file,
I have not defined route!
And in production, you’re not gonna get
that screen we saw with the Rails version
and the Ruby version, that is only for development.
So in production, you actually need
to manually specify the route.
So, we can go down here, and uncomment this,
that sets what the route is going to be,
we’re just gonna point it to post stud index.
We can save that, check in that save change,
and then we can run Kamal deploy again!
And that’s basically the rhythm you will be in
when you’re working on a Rails application
and you’re deploying to production.
If we go back here and reload not in production, boom!
We are live in production with our whole setup,
everything is working,
we can upload the active storage files directly to it.
By default,
Kamal will use a docker volume to start these things up,
but of course, you can configure that,
and as I said, you can use S3 if you’d like as well!
Common system is of course there as well,
let’s add one of those comments,
and now we have the entire application
running in production, wasn’t that easy?
Now, let’s add authentication to things as well.
Authentication is one of the newer features in Rails,
it basically gives you a default setup
for tracking sessions, tracking passwords,
and even doing password resets.
What it does not give you is a signup flow,
because that’s usually quite specific
to a given application.
So, we leave that as an exercise for the reader!
But as you can see here, it adds a handful of migrations,
one for users, and one for sessions!
So, we’re gonna run Rails db:migrate again!
And then, we are going to hop in here
and have a look at what was actually generated.
We have the sessions controller,
that’s probably the most important.
You can see here,
it allows unauthenticated access to just new and create.
Everything else by default
will be behind the authentication lock!
There’s also a rate limit to make sure
that people don’t bombard you with attempts to log into
users do not have access to.
And then, we do the authentication
using the email address and passwords,
and start a new session from there.
If we hop to the session,
you can see it just is very basic Rails active record.
Now, we’re gonna set up
a default user that the systems should have
as we’re working with it to allow us
to log in since we don’t have that signup flow.
So that’s just gonna be my email address
and 1, 2, 3 password!
We can hop back into our CLI
and run Rails db:seed, that’s gonna run that file
I just showed you and set things up.
Now, if we hop back onto local host
and we try to log in
with first the wrong (chuckling) password,
we’re actually gonna see something here
when I added the authentication, it added another gem,
it added bccrypt,
that’s what we’re using to keep password secure,
so we have to hop back in here
and restart our development server!
As we edit a new dependency, we can hop back in, reload,
and now we’re good to go here.
As you can see, I first tried to put in a wrong password,
we’re gonna get this screen,
try another email address or password.
But if I log in with 1, 2, 3, boom, I’m in!
Now, let’s add a way to sign out to
the main
layout here!
We can add that with a button to sign out.
It’s gonna hit the session path,
and it’s gonna use a method of delete to delete that session
if we’re authenticated, as you can see there.
So, it’s not gonna show that button
if we’re not already authenticated,
which is good because this layout is also used for login.
All right, let’s save that and hop back,
and see a reload here, now, we have a a sign out button,
and we can sign out, and that’s all us, it should be,
let’s deploy this to production,
we’re gonna just check this thing
into Git, deploy it straight to production,
go back to our alpha software, boom, dhh 123.
Oops! That didn’t work! Why did that not work?
Because we had not run our DB seeds!
Now, I could run DB seeds in production,
but lemme show you another way of doing it.
Kamal also gives you a way
to start a console on the server side
that is just like the console I showed you earlier
that ran in development!
You can see here, it reminds you that you are in production.
So, be careful when you (chuckling) create things
that are gonna be created on the server side
in your real database.
The database, by the way?
We haven’t talked much about that,
and that is because we’re using SQLite.
So, there is nothing to configure,
there’s nothing to set up, SQLite is now a suitable database
for production with Rails.
We have tuned it with all the right pragmas
and everything that you need
to run SQLite well in production,
you of course still need to set up a way to back that up,
but everything else is preconfigured for you.
So now, we’ve created that user in production
using our Kamal console!
I can log in with that user, 1, 2, 3, and boom,
we are in with production authentication
for the entire system.
All right!
One last thing,
let me show you how to turn this web application
into a PWA as well.
We’re gonna create a link reference here
to a manifest, that manifest just exists here
as a comment that you can reference.
We’re gonna turn the manifest on in our route file as well.
There are basically two lines here,
as you can see, there’s a manifest,
and there’s a service worker that you can use for your PWA.
We’ll turn those on and I’ll show you the manifest first.
The manifest is just really basic.
It’s gonna show the name of the PWA you’re gonna using!
And it’s gonna refer to an icon,
by default, we just have a nice red dot.
But you should obviously replace that
with your application icon.
And if I hop in
and have a look at the service worker,
it is sort of already set up for doing web push,
just as an example here, having some listeners,
you can tweak that as you see fit.
We’re not gonna change that for this little example,
but now let’s check in that PWA files,
and then let’s deploy to production one more time.
And as you can see,
look in the top right corner, when I reload it,
we now have that little install icon in Chrome.
And if I click that little install icon,
I’m gonna get this prompt, and boom!
I have a PWA
running in production for my Rails application.
So that is a very quick tour of Rails,
this is a wonderful way of getting started,
just to use those scaffold generators
and the authentication generators to get something going,
get a Hello world out there,
start working on your application,
and before you know it,
you might just be taking your application
all the way from Hello World to IPO.
