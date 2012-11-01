!SLIDE title-slide subsection

# validations #

!SLIDE 

# Validations

* validations are declared on the model
* checked every time data is saved to the database
* if data does not conform, error are available through the object

!SLIDE 

# Validations


    @@@ ruby
    > t = Tweet.new
    => #<Tweet id: nil, status: nil, zombie: nil>
    > t.save
    => false
    > t.errors
    => {:status=>["can't be blank"]}
    > t.errors[:status]
    => "can't be blank"


!SLIDE title-slide subsection

# 1:n Associations #

!SLIDE incremental smaller

# 1:n Associations

* 1:n associations are declared in the model with `belongs_to` and `has_many`:
* Zombie has many tweets, Tweet belongs_to zombie.
* add the foreign key to the appropriate database table using a migration!
* `add_column    :tweets, :zombie_id, :integer`
* both directions are now available in the objects:
* `t = Tweet.find(7); z = t.zombie`
* `z = Zombie.find(1); z.tweets.each{ |t|  puts t.status }`

!SLIDE title-slide subsection

# Now do 'Rails for Zombies' Episode #1
