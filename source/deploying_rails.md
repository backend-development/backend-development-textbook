Deploying Rails
==========================

Your "Minimal Viable Product" is finished, now you
want to publish it on the web.

After working through this guide you should be able to

* deploy a rails app to heroku using git
* deploy a rails app to any unix server using capistrano

-------------------------------------------------------------

Deploying with git
---------------------

heroku is one "Platform as a Service" provider that offers
to host your rails app.  Heroku uses git to push the code to
the production server.

(See also 
[Railsbridge Installfest: Create A Heroku Account](http://installfest.railsbridge.org/installfest/create_a_heroku_account)
and
[Railsbridge Installfest: Create And Deploy A Rails App](http://installfest.railsbridge.org/installfest/create_a_heroku_account#step7)
)


* create an account on https://heroku.com
* add your public key to your heroku account
* install the heroku toolbelt on your local development machine

in your rails app, which is already using git:

* heroku create
* make some changes in the Gemfile (rubyracer, pg instead of sqlite)
* don't forget to commit all changes!  
* git push heroku master
* heroku run rake db:migrate
* heroku open  
* heroku logs

That's it.   You should now have an app with a very strange URL, like
[http://mighty-shore-1497.herokuapp.com/](http://mighty-shore-1497.herokuapp.com/)

Public Key Authentication in SSH
---------------------

(See also [Railsbridge Installfest](http://installfest.railsbridge.org/installfest/create_an_ssh_key))


![public key login](images/public_key_crypto.svg)

* [learn about ssh](http://dougvitale.wordpress.com/2012/02/20/ssh-the-secure-shell/)
* if you have a public + private key pair
  * `id_rsa`
  * `id_rsa.pub`
* and your private key is on your local computer
  * stored in `~/.ssh/id_rsa`
* and your public key is on the server
  * stored in `~/.ssh/authorized_keys2`
* then ssh will let you log in without giving a password

![public key login](images/ssh_login_with_public_key.svg)


### deploying with a deploy-user

* alice and bob both want to deploy project x
* `deploy_x` is set up as an account on the server
* alice adds her public key to `~deploy_x/.ssh/authorized_keys2`
* bob adds his public key to `~deploy_x/.ssh/authorized_keys2`
* both can deploy (from different machines) using the same capistrano setup


### authorized_keys2

```
ssh-rsa AAAAB3NzaC...2EAAAABI== alice@fh-salzburg.ac.at
ssh-rsa AAAAB8NzaC...DVj3R4Ww== bob@fh-salzburg.ac.at
```


How to run Rails
---------------

* WEBrick (built in web server)
* apache/nginx + mod_passenger
* apache/nginx + mod_passenger + capistrano


### WEBrick

* rails s


### mod_passenger

* install [mod_passenger](https://www.phusionpassenger.com/)
* upload your code
* create files not in git (e.g. database.yml)
* apache config:
 * set `DocumentRoot` to `public/`
 * set `RailsEnv production`
* restart apache
* if you change the code:
 * touch `tmp/restart.txt` to force reload of code


Deploying with Capistrano
---------------

![Deploying with Javascript](images/capistrano-deploy.svg)

### WARNING

* capistrano is a command line tool
* you need to read the output!
* you need to read every line of the output!
* you seriously need to read every line of the output!


### capistrano assumptions

* You are using SSH to access your remote machines
* your remote servers have a shell called sh
* authentication through password or public key
* Capistrano reads its instructions from a `capfile`


### how to install

``` sh
$ sudo gem install capistrano
Fetching: capistrano-2.13.5.gem (100%)
Successfully installed capistrano-2.13.5
1 gem installed
$ $ cap install
mkdir -p config/deploy
create config/deploy.rb
create config/deploy/staging.rb
create config/deploy/production.rb
mkdir -p lib/capistrano/tasks
create Capfile
Capified
```


### configuration in `config/deploy.rb`

local information, see our wiki


### example task in Capfile

``` ruby
task :display_free_disk_space do
  run "df -h"
end
```


### prepare capistranoe

``` sh
$ cap production git:check
$ scp config/database.yml deployuser@server:/var/www/.../shared/config
$ scp config/secrets.yml deployuser@server:/var/www/.../shared/config
$ cap production deploy
```

### run a capistrano task

``` sh
$ cap production deploy
$ cap display_free_disk_space
* 2012-11-29 05:34:45 executing 'display_free_disk_space'
* executing "df -h"
  servers: ["multimediaart.at"]
  Password: ****
  [multimediaart.at] executing command
** [out :: multimediaart.at] Size  Used Avail Use% Mounted on
** [out :: multimediaart.at] 98G   70G   24G  75% /var/www
  command finished in 165ms
```




### capistrano folders

read the logfile, try to find out how capistrano lays out
the folders


* current --> links to a release
* release
  * 20121201113038
  * 20121201150544
* shared
  * assets  
  * bundle  
  * log  
  * pids  
  * system


### my first deploy

``` sh
$ cap deploy:setup
$ cap deploy:check
$ cap deploy:cold
$ cap deploy:upload FILES='config/database.yml'
```

