Ruby 
====

This guide will focus on ruby - the language - alone.

After finishing this guide you will

* have an overview of rubys type system
* be able to use list processing functions in ruby
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

Ruby is a thoroughly object oriented scripting language.
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
version control, ... when you learn rails you also pick up a whole culture 
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

When you chose names for your objects, classes and methods
you should stick to the following conventions to avoid
confusing other ruby developers:

``` ruby
the_variable = SomeClass.new
             # variables are written in snake_case
             # classes in capital CamelCase

             # method names are written in snake_case
a = b.sugar  # a method the returns something 
b.sweet?     # a method that returns true or false 
             # ends in a question mark
b.sugar!     # a method that changes its object 
             # ends in an exclamation mark
```

In the last to examples the punctuation marks are really
part of the method name!


The parantheses around a methods arguments are optional.
Leave them off unless your code get's confusing:

``` ruby
puts("less code")
puts "less code" 
```

# Data Types 

All of rubys basic data types are Classes.

* Numeric, Integer, Fixnum, Bignum, Float # are converted automatically to each other
* Ranges
* String
* true  # TrueClass
* false # FalseClass
* Symbol
* Array
* Hash
* Object
* Regex

### Strings

``` ruby
s = 'just a string of characters'
s = "string with #{the_variable} or even #{a+b/c} a ruby expression embedded"
s = <<EOM
This is a so called "Here-Document"
it can contain many lines of text
and ends with the identifier EOM (that i chose!)
but only if it's alone on a line all by itself:
EOM 
```

### Boolean Values

In ruby only `false` and `nil` are treated as false. This might
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

### Shorthand version of Conditions

The two conditions shown in the last
code block only have one statement inside
the block.  

This can also be written in another way by
appending the condition to the statement,
like so:

``` ruby
puts '0 is true!' if 0 
puts '"false" is not false' if "false"
```

This syntax should be familiar to you if
you understand english.  (yes, that's an english
sentence using the same syntax).

### Boolean Operators

When ruby evaluates a boolean operator,
it does as little work as possible.  It 
stops evaluation as soon as the result is clear:

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
# here input_value might be set...
a = input_value || default_value
```


### Methods

Methods in ruby return the last expression - even
if no explicit `return` statement is given.

``` ruby
def f(a,b)
  "x"
end

f(1,42)  # returns "x"
```

### Arrays

There are several ways of writing literal arrays in ruby.
The first one looks like JSON:

``` ruby
a = ["this", "that", "something"]
=> ["this", "that", "something"]
```

For creating an array of words (strings without whitespace in them)
you can use `%w`:

``` ruby
>> a = %w(this that something)
=> ["this", "that", "something"]
```

When creating an array of consecutive numbers you can
use a Range and convert it to an Array:

``` ruby
>> (1..4).to_a
=> [1, 2, 3, 4]
```

### Hashes

A Hash is a datastructure similar to an array. An array uses integers as
the index while a Hash takes any object. Mostly strings and symbols
are used as keys:

``` ruby
h = Hash.new
h["alice"] = "beer"
h["chris"] = "tea"
h["bob"] = "mate"
``` 

But you can use other objects:

``` ruby
t = Date.new
h[t] = "recently"
``` 

The data structure behind a ruby Hash is more complex
than an array: The key is sent though a function  (called hashfunction)
that returns a number. This number is used as the index
for an array.  If the hashfunction for two keys is the
same a linked list is built.


![How Hash(tabl)es work](images/hash_table.svg)

This datastructure seems like an serious waste of memory
at first. But it offers the following intresting features:

* looking up a key can be accomplised in constant time
* inserting a new key / value pari can be accomplised in constant time

Most scripting languages offer Hashes as a basic data type,
most compiled languages as a library.  Read more about
hashes in Wikipedia:

* [Hashtables in Wikipedia](http://en.wikipedia.org/wiki/Hash_table)


Enumerables and Piping Data
----------------------------

When working with a list of values ruby
helps you think about data on a new, more abstract level
with Enumerables:

### "Piping Data"

From the UNIX shell you may now the concepts of piping data
from one command to the next:

``` shell
# many httpd processes are running. as which user(s) ?
# 
$ ps aux | grep httpd | cut -c1-8 | sort | uniq
```

Each of those programs reads data from "Standard Input" and
writes data to "Standard Output".  The vertical bar symbol takes
the output of the preceding program and sends it input the next
program.  The data in question is plain text, consisting
of several lines.

Try it out on your commmand line by building up
the pipe step by step:

``` shell
$ ps aux | less
$ ps aux | grep httpd | less
$ ps aux | grep httpd | cut -c1-8 | less
$ ps aux | grep httpd | cut -c1-8 | sort | less
$ ps aux | grep httpd | cut -c1-8 | sort | uniq | less
```

### Piping Data in Ruby

When piping data in ruby you can start with
an Array

``` ruby
languages = %w[Fortran Ada C C++ Java Scala Haskell]
languages.sort.first(3)
```

Here are some simple methods you can use on Arrays (and other Enumerables)
that return a new Array.  You can connect theses methods to each other:

* sort
* first(n)
* drop(n)
* last(n)
* grep(/pattern/)
* reverse

Some other methods return just a single value, and thus end the pipe:

* count
* count("only this exact value")
* max
* min

More advanced methods take a Block (of code) as their argument.
The method `map` applys the Block to each piece of data, and
returns an Array of the now data:

``` ruby
>> (1..10).map{ |x| x*2 }
=> [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
>> (1..10).map{ |x| x*2 }.reverse
=> [20, 18, 16, 14, 12, 10, 8, 6, 4, 2]
```

If the computation is more complex you can write
the Block on several lines, ending with `end`

``` ruby
>> (1..10).map do |x|
?>   x*2
>> end
=> [2, 4, 6, 8, 10, 12, 14, 16, 18, 20]
>> (1..10).map do |x|
?>   x*2
>> end.reverse
=> [20, 18, 16, 14, 12, 10, 8, 6, 4, 2]
```


Some other methods for Enumerables that take a Block:

* map {|x| new value computed from x} 
* select {|x| should x be selected? }
* reduce(:+)
* reduce{|memo, item| compute new value for memo}


These methods should help you avoid loops and thus simplify
code considerably.



Blocks 
------

Blocks of code are not just used in Enumerables, they are
ab basic building block of ruby.  You can write functions
that take a Block as an argument:

### My Function takes a Block of Code 
as its last argument

``` ruby
def my_function_with_block_arg
  puts "code in the funtion"
  yield
  puts "more code in the function"
end

my_function_with_block_arg { puts "code in the block" }

# OUTPUT:
# code in the funtion
# code in the block
# more code in the function
```

Alternate syntax for defining the Block when calling the function:

``` ruby
my_function_with_block_arg do
  puts "code in the block"
  puts "more code in the block"
end
```

Ruby Style
----------

[Githubs Style Guide](https://github.com/styleguide/ruby) is good enough
for you!

Summary
-------

You now know about the basic data types, about enumerables and about block -   
features that distinguish ruby from other scripting languages. This should
be a good anough basis to digg deeper into rails next.  

But do take every
oppertunity you got to learn more about ruby itself: if you are unsure about
a line of code, look it up in the ruby documentation and use the
opportunity to read a bit more than strictly necessary.
I can highly recommend getting an offline version of the documentation
installed on your development machine, so you can use it even if you
are offline.



But you should come back and learn more about ruby later on.

* TODO: link to ruby documentation
* TODO: link ruby off rails
