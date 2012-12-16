Ruby Day
========

This guide will focus on ruby, the language.

After finishing this guide you will

* understand this
* do that

-----------------------------------------------------------------------

What is Ruby
------------

![Ruby Logo](images/Ruby_logo.png)

* an open source project
* one of the scripting language with p(?)
  * perl
  * python
  * <strike>php</strike>
* created by Yukihiro 'Matz' Matsumoto
* started in 1996


### What is ruby on rails

![Ruby on Rails Logo](images/Ruby_on_Rails_logo.png)

* web framework written in ruby
* created by David Heinemeier Hansson 'DHH'
* starting in 2005


### Why Ruby? Why Rails ?

![Ruby and Rails T-Shirts](images/ruby-and-rails-t-shirts.png)


Ruby Basics (Recap)
-------------------

### Conventions for Identifiers

* eine_variable
* EineKlasse
* a = b.sugar
* b.sugar!
* b.sweet?


### parantheses are optional!

``` ruby
puts("less code")
puts "less code" 
```


### Data Types

* Fixnum, Bignum, Float
* String
* true, false
* Symbol
* Array
* Hash
* Object


### String

``` ruby
s = 'nur ein String'
s = "string mit #{variable} oder #{a+b/c} Expression"
s = <<-EOM
This is a so called "Here-Document"
it can contain many lines of text
and ends with the identifier EOM (that i chose!)
EOM 
```



### only false and nil are treated as false

``` ruby
if 0 
  puts '0 is true!' 
end
if "false"
  puts '"false" is not false'       
end
```


### shorter way of writing a condition

``` ruby
puts '0 is true!' if 0 
puts '"false" is not false' if "false"
```


### shortcut evaluation of boolean operators

``` ruby
default_value = "gray"
input_value = nil
a = input_value || default_value
```



### Methode 

``` ruby
def f(a,b)
  "x"
end

f(1,42)
```


Enumerables and Piping Data
----------------------------


### What is a Hash?

* how does it work
* complexity of insert
* complexity of loopup


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


