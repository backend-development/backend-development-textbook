!SLIDE title-slide subsection

# rails with scaffold #

we will build our first rails project

but we will not really understand everything



!SLIDE 
# Rails from the outside in

!SLIDE incremental smaller
# database - model - view - controller

* example: course management system for a university
* sqlite as relational database, has a table 'courses'
* model has a class 'Course'
* view - several templates for courses
* controller - ties all the pieces together
* routing - maps URLs + parameters to controller

!SLIDE
# start a rails project

rails new alljokes -T


!SLIDE smaller
# rails directory structure

* Gemfile - which libraries (gems) does this project use?
* app
  * model
  * view
  * controller
* config
  * database.yml - database configuration
  * routes.rb 
* public - the webspace. files in here are accessible without routing

!SLIDE
# start the rails server

        @@@ sh 
        $ rails server

point your browser at http://localhost:3000/



!SLIDE
# the end
