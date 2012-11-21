!SLIDE title-slide subsection

# Rails Environments


!SLIDE incremental

# Three pre-defined Environments

* development - optimized for debugging
* testing
* production - optimized for speed, stability

!SLIDE incremental 

# How to Configure

* config/environments/development.rb
* config/environments/production.rb

!SLIDE incremental 

# How to use different environment

* webrick server: `rails server -e production`
* Rake tasks: add `RAILS_ENV="production"` at the end of the command.
* Rails console: `rails console production`

!SLIDE incremental smaller

# Asset Pipeline (since Rails 3)

*   source in `app/assets/*`
*   `rake assets:precompile`
*   assets in `public/assets/*`
*   can be served by web server, without going through the rails stack
*   `public/assets/manifest.yml`
* files look like this: `application-107e9bb2ab22174acce34bbbbe8f6d7f.css`
* expires header is set far into the future
* change in file --> new file name
