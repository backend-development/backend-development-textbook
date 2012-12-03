!SLIDE title-slide subsection

# capistrano

!SLIDE

# WARNING

* capistrano is a command line tool
* you need to read the output!
* you need to read every line of the output!
* you seriously need to read every line of the output!

!SLIDE incremental

# capistrano assumptions

* You are using SSH to access your remote machines
* your remote servers have a shell called sh
* authentication through password or public key
* Capistrano reads its instructions from a `capfile`

!SLIDE

# how to install

    @@@ sh
    $ sudo gem install capistrano
    Fetching: capistrano-2.13.5.gem (100%)
    Successfully installed capistrano-2.13.5
    1 gem installed
    $ capify .
    [add] writing './Capfile'
    [add] writing './config/deploy.rb'
    [done] capified!

!SLIDE

# configuration in `config/deploy.rb`

local information, see our wiki

!SLIDE

# example task in Capfile

    @@@ ruby
    task :display_free_disk_space do
      run "df -h"
    end

!SLIDE smaller

# run a capistrano task

    @@@ sh
    $ cap display_free_disk_space
      * 2012-11-29 05:34:45 executing 'display_free_disk_space'
      * executing "df -h"
        servers: ["multimediaart.at"]
        Password: ****
        [multimediaart.at] executing command
     ** [out :: multimediaart.at] Size  Used Avail Use% Mounted on
     ** [out :: multimediaart.at] 98G   70G   24G  75% /var/www
        command finished in 165ms

!SLIDE smaller incremental

# public key authentication in ssh

* [learn about ssh](http://dougvitale.wordpress.com/2012/02/20/ssh-the-secure-shell/)
* if you have a public + private key pair
 * `id_rsa`
 * `id_rsa.pub`
* and your private key is on your local computer
 * stored in `~/.ssh/id_rsa`
* and your public key is on the server
 * stored in `~/.ssh/authorized_keys2`
* then ssh will let you log in without giving a password


!SLIDE smaller incremental

# deploying with a deploy-user

* alice and bob both want to deploy project x
* `deploy_x` is set up as an account on the server
* alice adds her public key to `~deploy_x/.ssh/authorized_keys2`
* bob adds his public key to `~deploy_x/.ssh/authorized_keys2`
* both can deploy (from different machines) using the same capistrano setup

!SLIDE

# authorized_keys2

    @@@
    ssh-rsa AAAAB3NzaC...2EAAAABI== alice@fh-salzburg.ac.at
    ssh-rsa AAAAB8NzaC...DVj3R4Ww== bob@fh-salzburg.ac.at


!SLIDE

# capistrano folders

read the logfile, try to find out how capistrano lays out
the folders

!SLIDE

# capistrano folders

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

!SLIDE smaller

# my first deploy

      @@@ sh
      $ cap deploy:setup
      $ cap deploy:check
      $ cap deploy:cold
      $ cap deploy:upload FILES='config/database.yml'


