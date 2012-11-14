!SLIDE title-slide subsection

# models are more


!SLIDE incremental

# more than Object <-> Database Mapping

* business logic
* offer a different interface than the database!
* "virtual attributes"

!SLIDE 

# virtual attribute: getter

is computed from two other attributes, does not really
exist in the database.

    @@@ ruby
    def fullname
      [first_name, last_name].join(' ')
    end


!SLIDE 

# virtual attribute: setter

is computed from two other attributes, does not really
exist in the database.

    @@@ ruby
    def full_name=(name)
      split = name.split(' ', 2)
      self.first_name = split.first
      self.last_name = split.last
    end

!SLIDE 

# virtual attributes

see [Railscast #16](http://railscasts.com/episodes/16-virtual-attributes?view=asciicast)



!SLIDE 

# user-model for authentication

* Class User offers access login, email, firstname, lastname, password, password_confirmation
* Class User writes to Database:  firstname, lastname, email, login, crypted_password, salt


