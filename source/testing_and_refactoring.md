Testing and Refactoring
=======================

This guide will explain why you should write tests
for your web application. It covers built-in mechanisms offered by Rails.
By referring to this guide, you will be able to:

* Understand Rails testing terminology
* Write unit and integration tests for your application

<dd class="work-in-progress"><p>This chapter is still a work in progress. </p>
<p>You can help by reviewing the documents and posting your comments and corrections.</p></dd>

---------------------------------------------------------------------------

Why Test?
----------

* to know if the program works (as specified)
* to know if it still works after refactoring
* to know if it still works after adding a new feature
* to know if it still works ...


### for beginners: two testing levels

* unit testing - models
* integration testing - like a browser


### rails and testing

* testing built in
* scaffold creates (empty) tests
* testing environment
* run all tests with `rake:test`
* run all tests with `rake test TESTOPTS="-v"`



### my first test

``` ruby
# in file test/unit/user_test.rb
test "no_stars is zero in new user" do
  u = User.create!(:first_name=>"John", :last_name=>"Doe")
  assert u.no_stars == 0
end
```


### my first integration test

``` ruby
test "users are displayed" do
  u = User.create!(:first_name=>"Jane", :last_name=>"Doe")
  visit "/users"
  assert page.has_content?('Gib ein Sternchen!')
  assert page.has_content?('Jane Doe')
end
```


### see documentation

* [Guide to Testing Rails Applications](https://guides.rubyonrails.org/testing.html)
* [Test::Unit Cheatsheet](https://topfunky.com/clients/rails/ruby_and_rails_assertions.pdf)
* [Capybara Cheat Sheet](https://gist.github.com/3942267)


Test Driven Development (TDD)
-------------------------------

### what is "test first" ?

1. write a test (it fails)
2. write the implementation (test still fails)
3. fix the implementation 
4. test passes: you're done!


### what is "TDD" ?

1. Q: what should the program do? 
2. A: integration test. (write it. it fails)
3. Q: how should the program do it?
4. A: unit test. (write it. it fails)
5. implement the unit 
6. does the unit test pass? if not, got back to 5
7. does the integration test pass? if not, go back to 3


Code Refactoring
------------------


### what is "code refactoring" ?

* "restructuring an existing body of code
* altering its internal structure
* without changing its external behavior"
* or for short:
* change your code:
* but only how you do it,
* not what you do.


### refactoring and testing


* run the unit test (it should be green)
* refactor
* run the unit test (it should still be green)
* done


