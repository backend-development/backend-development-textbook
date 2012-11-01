!SLIDE title-slide subsection

# Ruby Basics (Recap)

!SLIDE incremental

# Conventions for Identifiers

* eine_variable
* EineKlasse
* a = b.sugar
* b.sugar!
* b.sweet?

!SLIDE 

# parantheses are optional!

        @@@ ruby
        puts("less code")
        puts "less code" 


!SLIDE incremental

# Data Types

* Fixnum, Bignum, Float
* String
* true, false
* Symbol
* Array
* Hash
* Object

!SLIDE incremental

# String

        @@@ ruby
        s = 'nur ein String'
        s = "string mit #{variable} oder #{a+b/c} Expression"
        s = <<-EOM
        Ein sogenanntes "Here-Document"
        kann viele Zeilen Text enthalten
        und endet beim (selbst gewählten) Bezeichner EOM
        EOM 


!SLIDE 

# only false and nil are treated as false

        @@@ ruby
        if 0 
          puts '0 is true!' 
        end
        if "false"
          puts '"false" is not false'       
        end

!SLIDE 

# shorter way of writing a condition

        @@@ ruby
        puts '0 is true!' if 0 
        puts '"false" is not false' if "false"

!SLIDE 

# shortcut evaluation of boolean operators

        @@@ ruby
        default_value = "gray"
        input_value = nil
        a = input_value || default_value


!SLIDE incremental

# Methode 

        @@@ ruby
        def f(a,b)
          "x"
        end

        f(1,42)

