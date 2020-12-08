# Web Performance, Assets and Webpacker

A web site consist of many more files than just the
HTML documents we have been generating up to now:
css files, javascript files, image files, font files, ...

Webpacker is Rails' way of preparing
theses files for publication using current 
frontend tools.

By referring to this guide, you will be able to:

- keep your assets in the right place
- have all your assets compiled and minified for production
- by using the Rails Asset Pipeline for CSS and image
- by using Webpacker for JavaScript


---

## Web Performance

What do we mean by 'web performance'? From the viewpoint of one user,
the crucial value is the time it takes from requesting a page (by clicking a link
or button, or typing in an URL) to having the page displayed and interactive in your browser.
We will call this the 'response time'.

From the publishers point of view it might also encompass the question of
how many users you can serve (with acceptable response time) on a given
server. If you look at the question of how to serve more users in case
of more demand you enter the realm of 'scalability'. This is a more advanced
question that goes beyond the scope of this guide.

### Myths About Performance

If you have never studied this subject you might still have
an intuition about where performance problems come from.
Many beginners are fascinated by details of their programming
language like: `will using more variables make my program slower?`
or `is string concatenation faster than string interpolation?`.

These 'micro optimizations' are hardly ever necssary with modern
programming languages and computers. Using Rails, Postgres and a modern
hosting service you will have no trouble serving hundreds and thousands
of users a day and achieving adequate performance for all of them.

### Permature Optimization

Trying to 'optimize' you code if there is no problem, or
if you don't know where the problem is,
will make your code worse, not better.

Donald Knuth stated this quite forcefully:

"The real problem is that programmers have spent far too much time worrying about efficiency in the wrong places and at the wrong times; **premature optimization is the root of all evil**" -- [Donald Knuth](https://en.wikiquote.org/wiki/Donald_Knuth#Computer_Programming_as_an_Art_.281974.29)

Only after you have measured the performance indicators that are
relevant to your project, and only after you have found out
which part of the system is causing theses indicators to go over
the threshold of acceptable values, only then can you truly
start to 'optimize'.

### Measuring Web Performance

The "exceptional performance" group at Yahoo published the browser addon
`yslow` in 2007. It first measured performance and displayed the timing
of the different HTTP connections as a "waterfall graph":

![displaying http downloads with yslow](images/network-souders-2008.png)

(Image from Steve Souders [talk at Web 2.0 Expo](https://conferences.oreilly.com/web2expo/webexsf2008/public/schedule/detail/3321) in April 2008)

Each bar is one resource being retrieved via HTTP, the x-axis
is a common timeline for all. The most striking result you can read from
this graph: the backend is only responsible for 5% of the time in this
example! 95% of time is spent loading and parsing javascript and css files
and loading and displaying images!

This graph was later integrated into the developer tools
of several browsers, and into the online tool [webpagetest](https://webpagetest.org/).

**Firefox**

![network view in firefox](images/network-view-firefox.png)

**Chrome**

![network view in chrom](images/network-view-chrome.png)

### Rules...

Yahoo first published 14 rules for web performance in 2007, based
on the measurements back then:

- Make Less HTTP Requests
- Use a Content Delivery Network
- Avoid empty src or href
- Add an Expires or a Cache-Control Header
- Gzip Components
- Put StyleSheets at the Top
- Put Scripts at the Bottom
- Avoid CSS Expressions...
- Make JavaScript and CSS External
- Reduce DNS Lookups
- Minify JavaScript and CSS
- Avoid Redirects
- Remove Duplicate Scripts

Even with changing browsers and improving HTTP 1 to HTTP 2 and now HTTP 3 / QUIC
some of these are still very valid today.
But as a web developer you should always keep an eye on the changing
landscape of web performance! These rules and their priority will change!

## How Rails helps with Performance

### Static files are fastest

The first think to know is that assets do not need to be
served through the rails stack, but should be served by the
web server directly.  In the following diagram they are
called 'static files':

![MVC in Rails](images/rails-mvc.svg)

In production these should be static files.

In development we will write other files, that need to be compiled, optimized and / or concatenated to
create these static files.

- Compile to JavaScript (e.g. typescript, coffeescript,...)
- Compile to CSS (e.g. LESS, SASS)
- Minify and combine several JavaScript files into one
- Minify and combine several CSS files into one
- Optimize images
- Create several versions of pixel images
- Create CSS Sprites


### Rails Asset Pipeline

In a Rails 6 project The Rails Asset Pipeline handles everything except JavaScript.

- you put CSS (and less, sass, scss) files in `app/assets/stylesheets/*`
- you configure which CSS files are built and included in `app/assets/stylesheets/application.css`
- you put images in `app/assets/images/*`
- files for publishing are automatically created in `public/assets/*`

### Webpacker

Since Rails 6 webpack and yarn are included with Rails.
These frontend tools are used to generate the JavaScript,
and can be used for other assets.

The gem that handles the setup of webpack is called `webpacker`,
you can find it in the `Gemfile`.

JavaScript packages are installed using `yarn install --check-files`. Just like
`npm`, `yarn` reads the list of packages to install form `package.json` and
installs them to the folder `node_modules`.  The lockfile for `yarn` is called `yarn.lock`.
You should never find a `package-lock.json` file in your Rails folder.


### Rails Environments

Building assets works differently in different Rails Environments.
There are three environments that exist by default:

- `development`
  - this is the environment you have been working in until now,
  - it is optimized for debugging, shows error messages and the error console.
- `testing`
  - this is used for running the [automatic tests](testing.html).
- `production`
  - this is how the finished app will run after it is published,
  - it is optimized for speed and stability

How each envirnoments behaves is configured in files in `config/environments/*.rb`.

The development environment is used by default on your machine. If you deploy
to heroku or to another hosting server, production will be used there.

### Rails Environments and Assets

In `development` no assets will be written to `public/`. Instead
these files will be created on the fly by the Asset Pipeline and by `webpack-dev-server`.

If you look at the output of `rails s` or the logfile `log/development.log`
you will see messages from `webpack-dev-server` when this happens:

```
[Webpacker] Compiling...
[Webpacker] Compiled all packs in /Users/bjelline/teach-dev/backend-assign/a4_job_board/public/packs
[Webpacker] Hash: 83233949a2f44e57ae52
Version: webpack 4.44.2
Time: 1345ms
Built at: 08.12.2020 19:36:18
                                     Asset       Size       Chunks                         Chunk Names
    js/application-cd9baa997ab2a6e5febb.js   70.9 KiB  application  [emitted] [immutable]  application
js/application-cd9baa997ab2a6e5febb.js.map   80.2 KiB  application  [emitted] [dev]        application
                             manifest.json  364 bytes               [emitted]
Entrypoint application = js/application-cd9baa997ab2a6e5febb.js js/application-cd9baa997ab2a6e5febb.js.map
[./app/javascript/channels sync recursive _channel\.js$] ./app/javascript/channels sync _channel\.js$ 160 bytes {application} [built]
[./app/javascript/channels/index.js] 211 bytes {application} [built]
[./app/javascript/packs/application.js] 717 bytes {application} [built]
[./node_modules/webpack/buildin/module.js] (webpack)/buildin/module.js 552 bytes {application} [built]
    + 2 hidden modules
```

When you deploy to production, the assets will be built and stored in `public/`.

If you look at the generated HTML code on the production server,
you will only find two links: in production
the many css files have been concatenated into one `application*.css`, and
all JavaScript files have been concatenated into one `application*.js`:

```
<link rel="stylesheet" media="all" href="/assets/application-1ea07225edcc7e47.css"/>
<script src="/assets/application-58af49959ef0.js"></script>
```

You can also try out the production environment on your own machine:

- start the web server: `rails server -e production`
- rails console: `rails console -e production`
- other rails commands: add `RAILS_ENV=production` at the beginning or the end of the command.

### Fingerprinting for better Expiry

The filenames mentioned in the last chapter all contain a part that seems random:

- you named the file `slider.css`
- but it shows up as `slider-974d585dcb6f5aec673164664a4e49d5.css` in development
- and is part of `application-1ea07225edcc7e47.css` in production

Where do the extra characters come from and what do they mean?

These extra characters are the "fingerprint". It is computed from the full
content of the file. If only one byte changes in the file, the fingerprint will
be different.

This enables a neat trick concerning caching: You can set the expiry time
to infinite, every browser can save the file forever and never try to reload it.
If the contents of the file change, a new file with a new fingerprint in the name will
be generated, and the HTML-page will link to that file.

This way we avoid one the the [two hard problems in computer science](https://twitter.com/codinghorror/status/506010907021828096): cache invalidation.


## User Generated Content

The asset pipeline handles assets that are
added by developers during development.
Images uploaded by users in production
are handled by [activestorage](https://edgeguides.rubyonrails.org/active_storage_overview.html).

When you are using a PAAS to deploy your app there is no simple
way of storing uploaeded data: the [release](https://12factor.net/build-release-run)  cannot be
changed and should be deposable.  You need a [backing service](https://12factor.net/backing-services)
for storing files.  This can be another cloud service like S3 (storage only) or [cloudinary](https://cloudinary.com/) (storage and image processing)


## Further Reading

- Souders(2007): High Performance Web Sites. O'Reilly. ISBN-13: 978-0596529307.
- Souders(2009): Even Faster Web Sites. O'Reilly. ISBN-13: 978-0596522308.
- [The Web Performance (Advent) Calendar](https://calendar.perfplanet.com/2018/) new every year
