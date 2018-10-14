Rails: Associations and Validations
==========================

After working through this guide you should

* Be able to create models with associations to other models
* Be able to write validations to check data before it is saved in a model

REPO: Fork the [basic zombies](https://github.com/backend-development/advanced_zombies) repository.

The examples are taken from "Rails for Zombies", which used to be a free rails online course. 
Sadly it is no longer available.

-------------------------------------------------------------





Validations
------------

Validations are rules you want to enforce on the data in your models.

* validations are declared on the model
* they are checked every time data is saved to the database
* if the data does not conform to the validation, it is not saved, and the errors are available through the object

An example on the rails console: I try to create a new tweet and save it,
but it can't be saved because a validation is in place:

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


Associations
------------


### 1:n Associations

If you have used relational databases before you are probably familiar
with the different types of associations between database tables.  But even
if you have not, the first association is easy to understand:

```
One Zombie has many Tweets          One Tweet belongs to one Zombie

Zombie Ash  ----------------------- Tweet 'arg'
            \---------------------- Tweet 'aarrrrrgggh'
            \---------------------- Tweet 'aaaarrrrrrrrrgggh'

Zombie Sue ------------------------ Tweet 'gagaga'
```

How is this represented in database?

In the table `tweets` there is a column `zombie_id` which references `zombies.id`.
This column in `tweets` is called a "foreign key".

You can add this column using a migration `add_column    :tweets, :zombie_id, :integer`

How is this represented in the model?

* 1:n associations are declared in the model with `belongs_to` and `has_many`
* both directions are now available in the objects:
  * `t = Tweet.find(7); z = t.zombie`
  * `z = Zombie.find(1); z.tweets.each{ |t|  puts t.status }`





### Further reading

* The Rails Guides give a good introduction to a subject area:
* Rails Guide: [Active Record Validations and Callbacks](http://guides.rubyonrails.org/active_record_validations_callbacks.html)
* Rails Guide: [Active Record Associations](http://guides.rubyonrails.org/association_basics.html)
* Use the API Dock to look up the details:
* Rails @ API Dock: [find()](http://apidock.com/rails/ActiveResource/Base/find/class)
* Rails @ API Dock: [ActiveRecord Validations](http://apidock.com/rails/v2.0.3/ActiveRecord/Validations/ClassMethods/validates_presence_of)
* Rails @ API Dock: [ActiveRecord Associations](http://apidock.com/rails/v3.2.8/ActiveRecord/Associations/ClassMethods)
