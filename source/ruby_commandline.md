Ruby 
====

This guide will focus on ruby - the language - alone.

After finishing this guide you will

* have an overview of rubys type system
* be able to use list processing funktions in ruby
* be able to use blocks and `yield` in ruby.

-----------------------------------------------------------------------

What is Ruby
------------

![Ruby Logo](images/Ruby_logo.png)

Ruby is an open source project.  It was started
in 1996 by Yukihiro 'Matz' Matsumoto. He is still
the "benevolent dictator" who decides on the future of the language.

In a colossal break with tradition he did not
choose a name starting with p for his scripting language
(think perl, python, php) but opted for r instead.

Like python ruby is a modern, thoroughly object oriented scripting language.
Even basic data types are object:

``` ruby
1.to_s
=> "1"
```

In this example the number 1 is used as an object, the method `to_s` is
called on it.  The result is an Object of class String.

### What is ruby on rails

![Ruby on Rails Logo](images/Ruby_on_Rails_logo.png)

Ruby on Rails is a web framework written in ruby.
It was created by David Heinemeier Hansson ('DHH') starting in 2005.

Rails is famous for the high productivity it gives to developers. It
is often used in startups, where speed of delivery is very important.
Rails moves fast, new versions with major improvement appear about every 18
months.  The rails community values speed of development, DRY code, testing,
version control, ... when you learn rails you also pick up whole culture 
surrounding it.


### Why Ruby? Why Rails ?

Why should you use Ruby and Rails over other programming languages
and frameworks?  

* Because you want to be a highly productive web developer?
* Because you want to learn from the best?
* Because you want try out many different languages and many frameworks?

All these answers are equally valid.

Also, we have cool t-shirts:

![Ruby and Rails T-Shirts](images/ruby-and-rails-t-shirts.png)


Ruby Basics 
-----------

For a hands-on introdcution to ruby got to [try ruby](http://tryruby.org).
Then come back and read on:

### Some code conventions

Identifiers:

``` ruby
the_variable = SomeClass.new
             # variables are written in snake_case
             # classes in capital CamelCase

a = b.sugar  # a method the returns something
b.sweet?     # a method that returns true or false
b.sugar!     # a method that changes it's object
```

In ruby the parantheses around arguments are optional.
Leave them off unless your code get's confusing:

``` ruby
puts("less code")
puts "less code" 
```

# Data Types 

All of rubys basic data types are Classes.

* Fixnum, Bignum, Float # are convert automatically to each other
* String
* true  # TrueClass
* false # FalseClass
* Symbol
* Array
* Hash
* Object

### Strings

``` ruby
s = 'just a string of characters'
s = "string with #{the_variable} or even #{a+b/c} a ruby expression embedded"
s = <<-EOM
This is a so called "Here-Document"
it can contain many lines of text
and ends with the identifier EOM (that i chose!)
but only if it's alone on a line all by itselve:
EOM 
```

### Boolean Values

In ruby only false and nil are treated as false. This might
be confusing for programmers used to other languages with
more complex rules for truthyness:

``` ruby
if 0 
  puts '0 is true!' 
end
if "false"
  puts '"false" (the string) is not false'       
end
```

### shorthand for conditions

the two conditions shown in the last
code block only have one statement inside
the if block.  This can also be written
in another way:

``` ruby
puts '0 is true!' if 0 
puts '"false" is not false' if "false"
```

### Boolean Operators

When ruby evaluates a boolean operator it
only does as little work as necessary.

``` ruby
# the second argument is not evaluated!
a =  true || ...
a = false && ...
```

The boolean operators don't just return true or
false, they return the argument last evaluated.
This is often used to set a variable:

``` ruby
default_value = "gray"
input_value = nil
a = input_value || default_value
```


### Methods

Methods in ruby return the last expression - even
if no explicit `return` statement is given.

``` ruby
def f(a,b)
  "x"
end

f(1,42)
```

### Hashes

A Hash is a datastructure similar to an array, but it uses
arbitrary keys of any object type, not an integer index.

![How Hash(tabl)es work](images/hash_table.svg)

* how does it work
* complexity of insert
* complexity of loopup


* [Hashtables in Wikipedia](http://en.wikipedia.org/wiki/Hash_table)

Enumerables and Piping Data
----------------------------



### "Piping Data"

``` shell
# many httpd processes are running. as which user(s) ?
# 
$ ps aux | grep httpd | cut -c1-8 | sort | uniq
```

### Piping Data in Ruby

``` ruby
languages = %w[Fortran Ada C C++ Java Scala Haskell]
languages.sort.first(3)
```


### some methods for Enumerables

* sort
* first(n)
* drop(n)
* last(n)
* grep(/pattern/)
* count
* count("only this exact value")
* max, min



### methods for Enumerables that take a block


``` ruby
(1..10).map{ |x| x*2 }.reverse
```



### methods for Enumerables that take a block


``` ruby
(1..10).map do |x| 
  x*2 
end.reverse
```



### methods for Enumerables that take a block

* map {|x| new value computed from x} 
* select {|x| should x be selected? }
* reduce(:+)
* reduce{|memo, item| compute new value for memo}


### avoid loops!



Blocks etc.
-----------


### My Function takes a Block of Code 
as it's last argument

``` ruby
def my_function_with_block_arg
  puts "code in the funtion"
  yield
  puts "more code in the function"
end

my_function_with_block_arg { puts "code in the block" }
```


### My Function takes a Block of Code 
as it's last argument

``` ruby
def my_function_with_block_arg
  puts "code in the funtion"
  yield
  puts "more code in the function"
end

my_function_with_block_arg do
  puts "code in the block"
  puts "more code in the block"
end
```

Ruby Style
----------

[Githubs Style Guide](https://github.com/styleguide/ruby) is good enough
for you!
