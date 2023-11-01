# Rails: Associations and Validations

After working through this guide you should

- Be able to write validations to check data before it is saved to the database
- Be able to create models with associations to other models

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
  validates :status, :zombie, presence: true
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
    length: { is: 10 }
```

### Checking Uniqueness in ActiveRecord

Validations are checked by Ruby code **before** data is inserted
in the database. If you want to ensure that the e-mails of your users
are unique, you can do so in Rails, by adding

```ruby
  validates :email, uniqueness: true
```

The validation happens by performing an SQL query into the model's table, searching for an existing record with the same value in that attribute. An error is reported by
returning a false value from `save` and setting the `errors` attribute.

If we run this in the console we can see the SQL:

```ruby
railsconsole> u3 = User.new(name: 'Ash', email: 'b@a.com')
railsconsole> u3.save
  BEGIN
  SELECT 1 AS one FROM "users" WHERE "users"."email" = $1 LIMIT $2  [["email", "b@a.com"], ["LIMIT", 1]]
  INSERT INTO "users" ("name", "email", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "Ash"], ["email", "b@a.com"], ["created_at", "2020-11-24 10:02"], ["updated_at", "2020-11-24 10:02"]]
  COMMIT
```

We can see a transaction from `BEGIN` to `COMMIT`.

### Checking Uniqueness in the Database

You could also achieve the same effect using a [UNIQUE CONSTRAINT](https://www.postgresql.org/docs/current/ddl-constraints.html#DDL-CONSTRAINTS-UNIQUE-CONSTRAINTS) in your database:

```ruby
class AddUniqConstraint < ActiveRecord::Migration[6.0]
  def change
    add_index :users, :email, unique: true
  end
end
```

When Constraints in the Database are broken an exception is raised:

```ruby
railsconsole> u3 = User.new(name: 'Ash', email: 'b@a.com')
railsconsole> u3.save
  BEGIN
  INSERT INTO "users" ("name", "email", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "Ash"], ["email", "b@a.com"], ["created_at", "2020-11-24 10:12:25.789051"], ["updated_at", "2020-11-24 10:12:25.789051"]]
  ROLLBACK
Traceback (most recent call last):
        1: from (irb):2
ActiveRecord::RecordNotUnique (PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_users_on_email")
DETAIL:  Key (email)=(b@a.com) already exists.
```

You can see that the exception is of class `ActiveRecord::RecordNotUnique` and contains
a description "Key (email)=(b@a.com) already exists".


### Validations and Forms

Later, when we learn about Views and Forms, you will see
that the save / validate / errors lifecycle fits perfectly with
the way that forms are handled in Rails. See [Rails: View and Controller](/rails_view_and_controller.html)

## Associations

If you have used relational databases before you are probably familiar
with the different types of associations or relationships between database tables.

We will only look at 1:n Relationships for now.

### 1:n Associations

In this example of a 1:n ("one to n") Association, one Zombie
has many tweets, an and one Tweet belongs to exactly one Zombie:

```
One Zombie has many Tweets          One Tweet belongs to one Zombie

Zombie Ash  ----------------------- Tweet 'arg'
            \---------------------- Tweet 'aarrrrrgggh'
             \--------------------- Tweet 'aaaarrrrrrrrrgggh'

Zombie Sue ------------------------ Tweet 'gagaga'
```



### Database

In the table `tweets` there is a column `zombie_id` which references `zombies.id`.
This column in `tweets` is called a "foreign key".

### Create the Tables

The easiest way is to create Zombies first. Then you
can already reference them when you create Tweets:

```
rails generate model tweet status:string zombie:references
```

You can also add the column later, to an existing `tweets` table, using just a migration

```
$ rails generate migration AddZombieToTweets zombie:references
```

this will generate a migration with the following command

```ruby
    add_reference :tweets, :zombie, null: false, foreign_key: true
```

Remember: If you ever mistype your `rails generate ...` line, you can undo it by running `rails destroy ...`.

### Model

You have to declare associations in both models, by
editing the two files in `app/models/*.rb`.

1:n associations are declared with `belongs_to` and `has_many`:

```ruby
# in file app/models/zombie.rb
class Zombie < ApplicationRecord
  has_many :tweets   # needs to be added by hand
end

# in file app/models/tweet.rb
class Tweet < ApplicationRecord
  belongs_to :zombie  # was added by generator
end
```

Notice the plural used with `has_many` and the singular used with `belongs_to`.

### Methods

After running the migration there are now methods available to walk from one model to the other:

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


### n:m Associations

In this next example a comic(book) has many authors, and an author has created many comic(book)s.
In this case we first create the two models, and then add a join table with this generator:


```shell
rails generate migration CreateJoinTableComicAuthor comics authors
```

The identifier after "migration" is arbitrary, we could call it anything we want.  The
two table names will be sorted alphabetically, and a table `authors_comics` will be
created.  It will not haven an id, and just contain the two foreign keys.

### has_and_belongs_to_many

In the two model Classes we need to declare the n:m association like so:

```ruby
class Author < ApplicationRecord
  has_and_belongs_to_many :comics
end

class Comic < ApplicationRecord
  has_and_belongs_to_many :authors
end
```

§

Again we gain new methods for the two classes:


```ruby
a = Author.first
a.comics.create(name: 'Maus')
a.comics.create(name: 'Katze')
a.comics.each do |c|
  ...
end
```

Notice: we do not have a model that represents the join table.


### n:m Associations with additional Data

Sometimes we have a n:m association with additional data.
In the next example, a Reader can rate a Comic, by giving one to 5 stars,
and also write a review of the comic.

One Reader can do this for several Comics, and one Comic can have
reviews and ratings by several Readers.

In Ruby on Rails we want to have a model to represent the association and the data.
Let's call it "Review":

```
$ rails g scaffold Review comic:references reader:references star_rating:integer review:text
```

The resulting model will already include two `belongs_to` statements:

```ruby
class Review < ApplicationRecord
  belongs_to :comic
  belongs_to :reader
end
```

§

In the two other classes we will add `has_many` and `has many ... through`:

```ruby
class Reader < ApplicationRecord
  has_many :reviews
  has_many :comics, through: :reviews
end

class Comic < ApplicationRecord
  has_many :reviews
  has_many :readers, through: :reviews
end
```

§


Some examples of using this:

```ruby
the_reader = Reader.first
Review.create(comic: Comic.last, reader: the_reader, star_rating: 1)
the_reader.reviews.create(comic: Comic.first, star_rating: 5, review: 'I can not even begin to ...')
```


## Build the Database Schema migration by migration

When first starting on a new Rails project you might already
have  an idea of what the database will look like.
But to get to your ideal design, you have to break this
down into several generation steps, several migrations.

For each Model you create you can decide if you want to use `generate model` or
`generate scaffold`.  The scaffold will give you a full CRUD interface for the model.
You will not need this for all models, but using it for some models will
save you a lot of work!


## Further reading

- The Rails Guides give a good introduction to a subject area:
  - Rails Guide: [Active Record Validations and Callbacks](https://guides.rubyonrails.org/active_record_validations_callbacks.html)
  - Rails Guide: [Active Record Associations](https://guides.rubyonrails.org/association_basics.html)
- Use the [Rails API](https://api.rubyonrails.org/) documentation to look up the details:
  - [validates_presence_of](https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_presence_of)
  - [has_many](https://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many)
