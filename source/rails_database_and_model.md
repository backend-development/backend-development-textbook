Rails: Database and Model
=========================

Models are the basic Classes of a Rails Project.  The
data is actually stored in a relational database.

After working through this guide you should

* know this
* be able to do that

-------------------------------------------------------------


ActiveRecord
------------

* "Object Relational Mapper"
* Active Record is a pattern for working with a relational database in a object oriented language
* Rails implements the Active Record pattern in a class called ActiveRecord



### the mapping

* Database Table `courses` corresponds to...
* Class Course, defined in  `app/models/course.rb`

* One row in the Table `courses` corresponds to...
* one object of the class Course

* `SELECT * FROM courses WHERE id=7` corresponds to...
* `Course.find(7)` 


### how to build

with a scaffold:

* `rails generate scaffold tweet status:string zombie:string`
* look at the migration that was generated in `db/migrate/*create_tweets.rb`
* run the migration: `rake db:migrate`
* look at the model generated in `app/models/tweet.rb`
* add validations, associations to model



### work with the model interactively

You can use the rails console to work with
the model.  Any changes you make are really written
to the development database!


### Now do 'Rails for Zombies' Episode #1

![Rails for Zombies 1](images/rails-for-zombies-1.jpg)

### validations #


### Validations

* validations are declared on the model
* checked every time data is saved to the database
* if data does not conform, error are available through the object


### Validations


``` ruby
> t = Tweet.new
=> #<Tweet id: nil, status: nil, zombie: nil>
> t.save
=> false
> t.errors
=> {:status=>["can't be blank"]}
> t.errors[:status]
=> "can't be blank"
```


### 1:n Associations #


### 1:n Associations

* 1:n associations are declared in the model with `belongs_to` and `has_many`:
* Zombie has many tweets, Tweet belongs_to zombie.
* add the foreign key to the appropriate database table using a migration!
* `add_column    :tweets, :zombie_id, :integer`
* both directions are now available in the objects:
* `t = Tweet.find(7); z = t.zombie`
* `z = Zombie.find(1); z.tweets.each{ |t|  puts t.status }`


Rails for Zombies
------------------

Now do 'Rails for Zombies' Episode #2

![Rails for Zombies 2](images/rails-for-zombies-2.jpg)

### Further reading

* The Rails Guides give a good introduction to a subject area:
* Rails Guide: [Active Record Query Interface](http://guides.rubyonrails.org/active_record_querying.html)
* Rails Guide: [Active Record Validations and Callbacks](http://guides.rubyonrails.org/active_record_validations_callbacks.html)
* Rails Guide: [Active Record Associations](http://guides.rubyonrails.org/association_basics.html)
* Use the API Dock to look up the details:
* Rails @ API Dock: [find()](http://apidock.com/rails/ActiveResource/Base/find/class)
* Rails @ API Dock: [ActiveRecord Validations](http://apidock.com/rails/v2.0.3/ActiveRecord/Validations/ClassMethods/validates_presence_of)
* Rails @ API Dock: [ActiveRecord Associations](http://apidock.com/rails/v3.2.8/ActiveRecord/Associations/ClassMethods)
