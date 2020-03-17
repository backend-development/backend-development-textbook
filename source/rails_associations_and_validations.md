# Rails: Associations and Validations

After working through this guide you should

- Be able to write validations to check data before it is saved to the database
- Be able to create models with associations to other models

REPO: Continue to use the [basic zombies](https://github.com/backend-development/advanced_zombies) example.

The examples were inspired by "Rails for Zombies", which used to be a free rails online course.
Sadly it is no longer available.

---

## Validations

Validations are rules you want to enforce on the data in your models.

Validations are declared on the model. They are checked every time data is **saved to the database**. If the data does not conform to the validation, it is not saved, a false value is returned, and the error messages are available through the object.

§

An example on the rails console: I try to create a new tweet and save it,
but it can't be saved because a validation is in place:

```ruby
> t = Tweet.new
=> #<Tweet id: nil, status: nil, zombie: nil>
> t.save
=> false
> t.errors
=> {:status=>["can't be blank"]}
> t.errors[:status]
=> "can't be blank"
```

Notice that the `save` method does not raise an exception,
but rather just returns a `false`. It is up to the calling
code to handle the error!

### Defining a Validation

Validation are declared in the model:

```ruby
class Tweet < ApplicationRecord
  validates :status, :zombie presence: true
end
```

The presence validator calls the method [`blank?`](https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F) on each of the value to check if they are present.

### Other Validations

There are many more helpers to create validations:

```ruby
  validates :terms_of_service,
    acceptance: true
  validates :subdomain, exclusion: {
    in: %w(www wiki),
    message: "%{value} is reserved."
  }
  validates :coursecode, format: {
    with: /\A[a-zA-Z]+\z/,
    message: "only allows letters"
  }
  validates :size, inclusion: {
    in: %w(small medium large),
    message: "%{value} is not a valid size"
  }
  validates :name,                length: { minimum: 2 }
  validates :bio,                 length: { maximum: 500 }
  validates :password,            length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
  validates :width_in_cm,  numericality: true
  validates :games_played, numericality: { only_integer: true }
  validates :boolean_field_name, inclusion: { in: [true, false] }
  validates :email, uniqueness: true
  validates :email, confirmation: true
```

The confirmation validator checks that there are two properties: in the example
this will be the `email` property and the `email_confirmation` property. Both
need to be equal.

### Combining Validations

You can combine several properties that should be checked:

```ruby
  validates :name, :login, :email, presence: true
```

or you can combine several validations on one property:

```ruby
  :coursecode,
    format: { with: /\A[a-zA-Z]+\z/, message: "only allows letters" },
    length: { is: 10 }
```

### Validations vs Database Constraints

Validations are checked by Ruby code **before** data is inserted
in the database. If you want to ensure that the e-mails of your users
are unique, you can do so in Rails, by adding

```ruby
  validates :email, uniqueness: true
```

The validation happens by performing an SQL query into the model's table, searching for an existing record with the same value in that attribute. An error is reported by
returning a false value from `save` and setting the `errors` attribute.

You could also do this by adding a [UNIQUE CONSTRAINT](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS) in your database.

[comment]: # "It will be checked by the database.  An error is reported by raising an exception when the `safe` is called."

### Validations and Forms

Later, when we learn about Views and Forms, you will see
that the save / validate / errors lifecycle fits perfectly with
the way that forms are handled in Rails. See [Rails: View and Controller](/rails_view_and_controller.html)

## 1:n Associations

If you have used relational databases before you are probably familiar
with the different types of associations between database tables. But even
if you have not, the first association is easy to understand:

```
One Zombie has many Tweets          One Tweet belongs to one Zombie

Zombie Ash  ----------------------- Tweet 'arg'
            \---------------------- Tweet 'aarrrrrgggh'
            \---------------------- Tweet 'aaaarrrrrrrrrgggh'

Zombie Sue ------------------------ Tweet 'gagaga'
```

### Database

In the table `tweets` there is a column `zombie_id` which references `zombies.id`.
This column in `tweets` is called a "foreign key".

### Create the Database

You can either add this column when you first create Tweets:

```
rails generate model tweet status:string zombie:references
```

You can add the column later, to an existing `tweets` table, using just a migration

```
$ rails generate migration AddZombieToTweets zombie:references
```

this will generate a migration with the following command

```ruby
    add_reference :tweets, :zombie, null: false, foreign_key: true
```

Warning: in SQLite3 this will cause some problems ("SQLite3::SQLException: Cannot add a NOT NULL column with default value NULL"), please remove the `null: false,` part of the migration.

If you ever mistype your `rails generate ...` line, you can undo it by running `rails destroy ...`.

### Model

You have to declare associations in both models, by
editing the two files in `app/models/*.rb`.

1:n associations are declared with `belongs_to` and `has_many`:

```ruby
# in file app/models/zombie.rb
class Zombie
  has_many :tweets
end

# in file app/models/tweet.rb
class Tweet
  belongs_to :zombie
end
```

Notice the plural used with `has_many` and the singular used with `belongs_to`.

### Methods

There are now methods available to walk from one model to the other:

```ruby
# from zweet to zombie
t = Tweet.find(7)
z = t.zombie

# from zombie to tweets
z = Zombie.find(1)
z.tweets.each do |t|
  puts t.status
end
```

Again: notice the plural `tweets` and singular `zombie`.

§

You can also use a model to create associated models:

```ruby
z = Zombie.find(1)
z.tweets.create(status: "I'm alive!")
z.tweets.create(status: "Correction: I'm dead. But still moving.")
z.tweets.create(status: "Why did my arm just fall off?")
```

You can find a list of all the new methods added by the
association in the Rails Guide under [Methods Added by belongs_to](https://guides.rubyonrails.org/association_basics.html#belongs-to-association-reference) and
[Methods Added by has_many](https://guides.rubyonrails.org/association_basics.html#has-many-association-reference).

## Further reading

- The Rails Guides give a good introduction to a subject area:
  - Rails Guide: [Active Record Validations and Callbacks](https://guides.rubyonrails.org/active_record_validations_callbacks.html)
  - Rails Guide: [Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
- Use the [Rails API](https://api.rubyonrails.org/) documentation to look up the details:
  - [validates_presence_of](https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_presence_of)
  - [has_many](https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many)
