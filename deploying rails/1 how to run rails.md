!SLIDE title-slide subsection

# how to run rails

!SLIDE incremental

# how to run rails

* WEBrick (built in web server)
* apache/nginx + mod_passenger
* apache/nginx + mod_passenger + capistrano

!SLIDE 

# WEBrick

* rails s

!SLIDE incremental smaller

# mod_passenger

* install [mod_passenger](https://www.phusionpassenger.com/)
* upload your code
* create files not in git (e.g. database.yml)
* apache config:
 * set `DocumentRoot` to `public/`
 * set `RailsEnv production`
* restart apache
* if you change the code:
 * touch `tmp/restart.txt` to force reload of code

