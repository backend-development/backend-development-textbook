!SLIDE title-slide subsection

# Ruby Specialities

!SLIDE 

* (1) Enumerables, Arrays, Hashes
* (2) Blocks

!SLIDE 

# Enumerables, Arrays, Hashes

!SLIDE

# What is a Hash?

* how does it work
* complexity of insert
* complexity of loopup

!SLIDE smaller

# "Piping Data"

        @@@ shell
        # many httpd processes are running. as which user(s) ?
        # 
        $ ps aux | grep httpd | cut -c1-8 | sort | uniq

!SLIDE smaller

# Piping Data in Ruby

        @@@ ruby
        languages = %w[Fortran Ada C C++ Java Scala Haskell]
        languages.sort.first(3)

!SLIDE incremental smaller

# some methods for Enumerables

* sort
* first(n)
* drop(n)
* last(n)
* grep(/pattern/)
* count
* count("only this exact value")
* max, min


!SLIDE 

# methods for Enumerables that take a block


        @@@ ruby
        (1..10).map{ |x| x*2 }.reverse


!SLIDE 

# methods for Enumerables that take a block


        @@@ ruby
        (1..10).map do |x| 
          x*2 
        end.reverse


!SLIDE incremental

# methods for Enumerables that take a block

* map {|x| new value computed from x} 
* select {|x| should x be selected? }
* reduce(:+)
* reduce{|memo, item| compute new value for memo}

!SLIDE

# avoid loops!


!SLIDE smaller

# Blocks etc.

!SLIDE smaller

# My Function takes a Block of Code 
as it's last argument

        @@@ ruby
        def my_function_with_block_arg
          puts "code in the funtion"
          yield
          puts "more code in the function"
        end

        my_function_with_block_arg { puts "code in the block" }
        
!SLIDE smaller

# My Function takes a Block of Code 
as it's last argument

        @@@ ruby
        def my_function_with_block_arg
          puts "code in the funtion"
          yield
          puts "more code in the function"
        end

        my_function_with_block_arg do
          puts "code in the block"
          puts "more code in the block"
        end

!SLIDE 

