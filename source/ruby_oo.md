Ruby Object Orientation
====

This guide will take a closer look at objects, classes and modules in Ruby.

After finishing this guide you will

* know how to write object methods and use object variables (properties)
* know how to write class methods and use class variables (properties)




-----------------------------------------------------------------------


To Be Written
----------



## An investigation into Declarations:

In [Rails: Associations and Validations](rails_associations_and_validations.html) we learned that Validation are declared in the model:

``` ruby
class Tweet < ActiveRecord::Base
  validates_presence_of :status
end
```

But what is really happening here?


`validates_presence_of` is called when the class is defined.  it is called only once.

``` ruby
class Ruby
  def validates_presence_of x
    puts "I should really check for property #{x}"
  end

  validates_presence_of :color
end

# in `<class:Ruby>': undefined method `validates_presence_of' for Ruby:Class (NoMethodError)
```

`validates_presence_of`  cannot be a normal method, because such a method is not defined yet
when the class is defined.  so it needs to be a class method.


``` ruby
class Ruby
  def self.validates_presence_of x
    puts "I should really check for property #{x}"
  end

  validates_presence_of :color
end
```

....


``` ruby
class ValidatableStuff
  attr_accessor :data
  attr_accessor :errors
  def self.validates_presence_of x
    puts "the class #{self} should really check for #{x} - but how?"
    @@validator_for = x
  end

  def initialize(**data) 
    @data = data
  end

  def save
    puts "I am trying to save the data of a #{self.class} Object. the data is #{self.data}"
    if self.data.keys.include?( @@validator_for ) 
      puts "this is ok, #{@@validator_for} is set"
      return true
    else
      puts "this is not ok, #{@@validator_for} needs to be set"
      self.errors = "#{@@validator_for} needs to be set"
      return false
    end
    
  end
end


class Ruby < ValidatableStuff
  def x
  end

  x
  validates_presence_of :color
end


class Diamond < ValidatableStuff
  validates_presence_of :carat
end

r1 = Ruby.new
if r1.save 
  puts "saved"
else 
  puts "errors: #{r1.errors}"
end

r2 = Ruby.new(color: 'yellow')
r2.save

d1 = Diamond.new
d1.save

d2 = Diamond.new(carat: 10)
d2.save
```
### Online Resources

* [learningruby.com tutorial](http://rubylearning.com/satishtalim/tutorial.html)

### Books

* [Metz, Sandy(2017): Practical Object-Oriented Design in Ruby](https://www.poodr.com/)
