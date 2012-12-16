Rails with Scaffold 
===================

we will build our first rails project but we will not really understand
everything - that comes later.

After finishing this guide you will

* have finished your first rails project
* know how to use the scaffold generator
* know about the main folders of a rails project: config, db, app

-----------------------------------------------------------------------


Rails from the Outside In
-------------------------

### database - model - view - controller

* example: course management system for a university
* sqlite as relational database, has a table 'courses'
* model has a class 'Course'
* view - several templates for courses
* controller - ties all the pieces together
* routing - maps URLs + parameters to controller

### start a rails project

``` sh
rails new alljokes -T
```


### rails directory structure

* Gemfile - which libraries (gems) does this project use?
* app
  * model
  * view
  * controller
* config
  * database.yml - database configuration
  * routes.rb 
* public - the webspace. files in here are accessible without routing

### start the rails server

``` sh 
$ rails server
```

point your browser at http://localhost:3000/



### the end
