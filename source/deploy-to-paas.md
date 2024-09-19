Deploy to PAAS
=======================

Platform as a Service - PAAS - is one
way to deploy web apps.

After reading it you should

- know different cloud service models
- know some of the 12 factors of the 12factor App
- be able to deploy to dokku
- be able to deploy to heroku (warning: you need a credit card and have to pay)

---------------------------------------------------------------------------

## What is Cloud Computing?

When you want to publish your web application you can use your own
computer, connect it to the internet permanently, and do all the work
of maintaining the computer and the internet connection yourself.

Or you can use a service provider that takes care of part of the job.
Depending on how much you do yourself these services have different names.

This diagram [from redhat](https://www.redhat.com/en/topics/cloud-computing/what-is-paas) shows four different scenarios:

_On-site_, also called _on premise_, means running your own hardware in your own room
with your own internet connection.

The following three scenarios all fall under the termin "Cloud Computing":

With _Infrastructure as a Service_ the server is housed in a server room at the service
provider. Hardware, internet connecion, power are all taken care of. You rent a virtual
machine, sometimes with operating system preinstalled, and take care of everything form
the operating system upwards.

_Platform as a Service_ also takes care of the operating system (e.g. Linux),
running databases and other services and providing the interpreter or runtime for
the programming language. You rent space for your app plus the database(es) you need.

With _Software as a Service_ there is no app to deploy, the whole stack is in
the hands of the service provider.

![comparison of on premise, iaas, paas, saas](images/iaas-paas-saas.png)

For a company, moving from on premise to \*aas means employing
fewer sysadmins and buying less hardware. It also means
paying a lot of money to the service provider.

Which alternative is feasibly and which one is cheaper for a
specific project depends on many factors.

## Why use Cloud Computing?

The [NIST Definition of Cloud Computing](https://csrc.nist.gov/publications/detail/sp/800-145/final)
lists five essential characteristics of cloud computing. The short version is:

- _On-demand self-service_. A consumer can configure computing capabilities (storage, cpus,...) as needed, without human interaction with each service provider.
- _Broad network access_. Capabilities are available over the network and accessed through standard mechanisms.
- _Resource pooling_. The provider’s computing resources serve multiple consumers. Different physical and virtual resources are dynamically assigned and reassigned according to demand.
- _Rapid elasticity_. Capabilities can be elastically provisioned and released. To the consumer, the capabilities available for provisioning appear to be unlimited.
- _Measured service_. Resource usage can be monitored, controlled, and reported, providing transparency for both the provider and consumer of the utilized service.

## Public vs. Private Cloud

Any cloud infrastructure that is open for use by the general public is called a public cloud.
Public does not mean free, just that any paying customer can use it.
It exists on the premises of the cloud provider.

A private cloud would be a iaas, paas, or saas that is run for the
exclusive use of one organisation. To be called "cloud" it should
still exhibit the five characteristics above.

In this guide we will look at one example of a public paas (heroku)
und one example of a private paas (dokku).

## Using Heroku

you need to

- create an account on [heroku](http://heroku.com)
- give them your credit card number, this will cost!
- and install the [heroku command line interface (cli)](https://devcenter.heroku.com/articles/heroku-cli)
- add your public key to heroku by running `heroku keys:add`

## Using Dokku

if you are reading this as part of your course at Fachhochschule Salzburg
you already have an account on our local dokku install.

you need to

- install the [offical dokku client](http://dokku.viewdocs.io/dokku/deployment/remote-commands/#official-client)
- add the remote dokku to your repository (see internal wiki)

## The 12factor App

In 2011 the document "the 12factor app" was published by developers from
the company heroku. It describes how to prepare a web app
for running on a paas.

Many of these 12 factors have become commonplace for web development -
you probably have been doing some of it all along. But let's look
at each one in turn. A link to the original document is
always provided in the first sentence, please read the original first!


### I. Codebase

[One codebase tracked in revision control, many deploys](https://12factor.net/codebase)

Discussion:

in 2020, git is used for all new projects. In long running projects
you can still find some use of subversion.

"Multiple apps sharing the same code"
is explicitly discouraged for a 12 factor app. Here there is no industry consensus.
Some companys use one app per repo, some others use Monorepos that contain many
different apps and libraries, most famously Google. (If you have as much code
as google git will not suffice for a monorepo)

### II. Dependencies

[Explicitly declare and isolate dependencies](https://12factor.net/dependencies)

Dependency declaration through a file like `Gemfile`, `package.json`, `composer.json`
is available in all modern languages for the web.

### III. Config

[Store config in the environment](https://12factor.net/config)

You can see the environment variables in both dokku and heroku by
running the `config` command:

```
$ dokku config
=====> joe19 env vars
DATABASE_URL:             postgres://postgres:53dfe08f@dokku-postgres-joe19-db:5432/joe19_db
DOKKU_APP_RESTORE:        1
DOKKU_APP_TYPE:           herokuish
DOKKU_LETSENCRYPT_EMAIL:  brigitte.jellinek@fh-salzburg.ac.at
DOKKU_PROXY_PORT:         80
DOKKU_PROXY_PORT_MAP:     http:80:5000
GIT_REV:                  458ee39607212093fd02f0e10dfa9623d0c52951
REDIS_URL:                redis://dokku-redis-joe19-redis:6379
```

or for another app:

```
$ heroku config
=== obscure-springs-61542 Config Vars
DATABASE_URL:             postgres://erout:1baa7f8@ec2-34-200-106-49.compute-1.amazonaws.com:5432/d3jjlc4
LANG:                     en_US.UTF-8
RACK_ENV:                 production
RAILS_ENV:                production
RAILS_LOG_TO_STDOUT:      enabled
RAILS_SERVE_STATIC_FILES: enabled
SECRET_KEY_BASE:          39a9fdb1549bfc2042b1d227682d3a2a5eebd26377461a479c727f6f0ef
```

### IV. Backing services

[Treat backing services as attached resources](https://12factor.net/backing-services)

If you look back at the environment variables above
you can see the variable `DATABASE_URL`. This contains
all the information needed to connect to the database -
type of database, username, password, host, port, name of the database.

````
DATABASE_URL:             postgres://erout:1baa7f8@ec2-34-200-106-49.compute-1.amazonaws.com:5432/d3jjlc4
````

Here you can also see that Heroku uses Amazon AWS to run the database server.
To Heroku buys iaas from aws and sells paas to us.

### V. Build, release, run

[Strictly separate build and run stages](https://12factor.net/build-release-run)

Here we first meet a limitation of the 12 factor app when
we compare it to deploying PHP via SFTP:
It is impossible to make changes to the code at runtime.

If you change the code, you need to commit, push to the paas
and wait for a minute for it to deploy.

### VI. Processes

[Execute the app as one or more stateless processes](https://12factor.net/processes)

### VII. Port binding

[Export services via port binding](https://12factor.net/port-binding)

### VIII. Concurrency

[Scale out via the process model](https://12factor.net/concurrency)

### IX. Disposability

[Maximize robustness with fast startup and graceful shutdown](https://12factor.net/disposability)

### X. Dev/prod parity

[Keep development, staging, and production as similar as possible](https://12factor.net/dev-prod-parity)

Yes.

### XI. Logs

[Treat logs as event streams](https://12factor.net/logs)

You can see the log in both dokku and heroku by
running the `logs` command:

```
$ dokku logs
2020-11-17T23:12:05.303598065Z app[web.1]: I, [2020-11-17T23:12:05.303319 #13]  INFO -- : [ef9d04ac-57f3-43ff-ade8-4baae687ae62] Started GET "/users/65" for 193.170.119.70 at 2020-11-17 23:12:05 +0000
2020-11-17T23:12:05.305040861Z app[web.1]: I, [2020-11-17T23:12:05.304832 #13]  INFO -- : [ef9d04ac-57f3-43ff-ade8-4baae687ae62] Processing by UsersController#show as HTML
2020-11-17T23:12:05.305053742Z app[web.1]: I, [2020-11-17T23:12:05.304928 #13]  INFO -- : [ef9d04ac-57f3-43ff-ade8-4baae687ae62]   Parameters: {"id"=>"65"}
2020-11-17T23:12:05.307999933Z app[web.1]: D, [2020-11-17T23:12:05.307814 #13] DEBUG -- : [ef9d04ac-57f3-43ff-ade8-4baae687ae62]   User Load (0.6ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 ORDER BY "users"."id" ASC LIMIT $2  [["id", 1], ["LIMIT", 1]]
2020-11-17T23:12:05.309472306Z app[web.1]: D, [2020-11-17T23:12:05.309273 #13] DEBUG -- : [ef9d04ac-57f3-43ff-ade8-4baae687ae62]   CACHE User Load (0.0ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 ORDER BY "users"."id" ASC LIMIT $2  [["id", 1], ["LIMIT", 1]]
2020-11-17T23:12:05.310509308Z app[web.1]: D, [2020-11-17T23:12:05.310318 #13] DEBUG -- : [ef9d04ac-57f3-43ff-ade8-4baae687ae62]   User Load (0.5ms)  SELECT "users".* FROM "users" WHERE "users"."id" = $1 LIMIT $2  [["id", 65], ["LIMIT", 1]]
2020-11-17T23:12:05.311539723Z app[web.1]: I, [2020-11-17T23:12:05.311348 #13]  INFO -- : [ef9d04ac-57f3-43ff-ade8-4baae687ae62]   Rendering users/show.html.erb within layouts/application
2020-11-17T23:12:05.312788508Z app[web.1]: D, [2020-11-17T23:12:05.312634 #13] DEBUG -- : [ef9d04ac-57f3-43ff-ade8-4baae687ae62]    (0.5ms)  SELECT COUNT(*) FROM "stamps" WHERE "stamps"."user_id" = $1 AND "stamps"."stamped" = $2  [["user_id", 65], ["stamped", true]]
2020-11-17T23:12:05.313694774Z app[web.1]: D, [2020-11-17T23:12:05.313537 #13] DEBUG -- : [ef9d04ac-57f3-43ff-ade8-4baae687ae62]    (0.4ms)  SELECT COUNT(*) FROM "stamps" WHERE "stamps"."user_id" = $1 AND "stamps"."stamped" = $2  [["user_id", 65], ["stamped", false]]
```

or for another app:

```
$ heroku logs
2020-11-17T23:07:37.373849+00:00 heroku[router]: at=info method=GET path="/stylesheets/application.css" host=obscure-springs-61542.herokuapp.com request_id=d3e9ae87-bf4f-4c7e-b640-9663a184b8b5 fwd="193.171.53.146" dyno=web.1 connect=0ms service=3ms status=404 bytes=1902 protocol=https
2020-11-17T23:07:39.869495+00:00 app[web.1]: I, [2020-11-17T23:07:39.869410 #4]  INFO -- : [11aade3c-23be-4927-a1fb-73432521b203] Started GET "/drinks" for 193.171.53.146 at 2020-11-17 23:07:39 +0000
2020-11-17T23:07:39.870216+00:00 app[web.1]: I, [2020-11-17T23:07:39.870132 #4]  INFO -- : [11aade3c-23be-4927-a1fb-73432521b203] Processing by DrinksController#index as HTML
2020-11-17T23:07:39.871120+00:00 app[web.1]: I, [2020-11-17T23:07:39.871051 #4]  INFO -- : [11aade3c-23be-4927-a1fb-73432521b203]   Rendering drinks/index.html.erb within layouts/application
2020-11-17T23:07:39.873153+00:00 app[web.1]: D, [2020-11-17T23:07:39.873081 #4] DEBUG -- : [11aade3c-23be-4927-a1fb-73432521b203]   Drink Load (0.8ms)  SELECT "drinks".* FROM "drinks"
2020-11-17T23:07:39.873890+00:00 app[web.1]: I, [2020-11-17T23:07:39.873815 #4]  INFO -- : [11aade3c-23be-4927-a1fb-73432521b203]   Rendered drinks/index.html.erb within layouts/application (Duration: 2.6ms | Allocations: 288)
2020-11-17T23:07:39.874513+00:00 app[web.1]: I, [2020-11-17T23:07:39.874442 #4]  INFO -- : [11aade3c-23be-4927-a1fb-73432521b203] Completed 200 OK in 4ms (Views: 2.8ms | ActiveRecord: 0.8ms | Allocations: 885)
2020-11-17T23:07:39.875779+00:00 heroku[router]: at=info method=GET path="/drinks" host=obscure-springs-61542.herokuapp.com request_id=11aade3c-23be-4927-a1fb-73432521b203 fwd="193.171.53.146" dyno=web.1 connect=0ms service=7ms status=200 bytes=1937 protocol=https
```

### XII. Admin processes

[Run admin/management tasks as one-off processes](https://12factor.net/admin-processes)

You can run other processes in both dokku and heroku by
running the `run` command:

```
heroku run rails db:migrate
```

```
dokku run rails db:migrate
```

## First steps

1. create an app
2. set a new remote in your repository for heroko / dokku
3. push the main branch to the paas
4. run `rails db:migrate` on the paas

## See Also

- [NIST Definition of Cloud Computing](https://csrc.nist.gov/publications/detail/sp/800-145/final)
- [Anders Qvist: Twelve-factor app anno 2022](https://xenitab.github.io/blog/2022/02/23/12factor/)
