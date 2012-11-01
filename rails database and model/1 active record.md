!SLIDE title-slide subsection

# rails database and model #

!SLIDE 

# ActiveRecord

* "Object Relational Mapper"
* Active Record is a pattern for working with a relational database in a object oriented language
* Rails implements the Active Record pattern in a class called ActiveRecord


!SLIDE incremental smaller

# the mapping

* Database Table `courses` corresponds to...
* Class Course, defined in  `app/models/course.rb`

* One row in the Table `courses` corresponds to...
* one object of the class Course

* `SELECT * FROM courses WHERE id=7` corresponds to...
* `Course.find(7)` 

!SLIDE incremental smaller

# how to build

with a scaffold:

* `rails generate scaffold tweet status:string zombie:string`
* look at the migration that was generated in `db/migrate/*create_tweets.rb`
* run the migration: `rake db:migrate`
* look at the model generated in `app/models/tweet.rb`
* add validations, associations to model


!SLIDE 

# work with the model interactively

You can use the rails console to work with
the model.  Any changes you make are really written
to the development database!

!SLIDE title-slide subsection

# Now do 'Rails for Zombies' Episode #1

