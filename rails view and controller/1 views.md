!SLIDE title-slide subsection

# rails views #


!SLIDE incremental

# view in MVC

* responsible for displaying stuff
* both web designers and developers might work on these files!

!SLIDE incremental smaller

# rails views

* are stored in `app/views/<name of controller>/*.html.erb`
* template format `.erb` is html with embedded ruby:
* `<% ruby code here %>` just evaluates the code
* `<%= ruby code here %>` evaluates the code and includes result
* main template (for header, footer) in `app/views/layouts/application.html.erb`
* `yield`s to include single view

!SLIDE incremental

# static content

* anything placed in `public`
* is directly accessible in the web space, without going through rails!

!SLIDE incremental

# links

* never write links to your own app "by hand"!
* use helper methods to get the right URLs
* `link_to 'link text here', object` links to show action of the object
* use `rake routes` to find out the names of urls/paths

!SLIDE title-slide subsection

# Now do 'Rails for Zombies' Episode #3
