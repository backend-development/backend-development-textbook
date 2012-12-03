!SLIDE title-slide subsection

# why test?


!SLIDE incremental

# why test?

* to know if the program works (as specified)
* to know if it still works after refactoring
* to know if it still works after adding a new feature
* to know if it still works ...

!SLIDE 

# for beginners: two testing levels

* unit testing - models
* integration testing - like a browser

!SLIDE incremental

# rails and testing

* testing built in
* scaffold creates (empty) tests
* testing environment
* run all tests with `rake:test`
* run all tests with `rake test TESTOPTS="-v"`


!SLIDE smaller

# my first test

    @@@ ruby
    # in file test/unit/user_test.rb
    test "no_stars is zero in new user" do
      u = User.create!(:first_name=>"John", :last_name=>"Doe")
      assert u.no_stars == 0
    end

!SLIDE smaller

# my first integration test

    @@@ ruby
    test "users are displayed" do
      u = User.create!(:first_name=>"Jane", :last_name=>"Doe")
      visit "/users"
      assert page.has_content?('Gib ein Sternchen!')
      assert page.has_content?('Jane Doe')
    end

!SLIDE

# see documentation

* [Guide to Testing Rails Applications](http://guides.rubyonrails.org/testing.html)
* [Test::Unit Cheatsheet](http://topfunky.com/clients/rails/ruby_and_rails_assertions.pdf)
* [Capybara Cheat Sheet](https://gist.github.com/3942267)
    
