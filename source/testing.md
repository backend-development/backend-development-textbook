Getting Started with Testing
============================

This guide gives an introduction
to built-in mechanisms in Rails for testing your application.

After reading this guide, you will know:

* Rails testing terminology.
* How to write unit tests for your applications models and controllers
* How to write integration tests for your application.

This guide is a shorter version of the offical
[Guide to Testing Rails Applications](http://guides.rubyonrails.org/testing.html).

REPO: Fork the [example app 'testing for stars'](https://github.com/backend-development/rails-example-testing-for-stars) and try out what you learn here.

--------------------------------------------------------------------------------

Why Write Tests?
----------------

Rails makes it super easy to write your tests. It starts by producing skeleton test code while you are creating your models and controllers.

By running your Rails tests after every change in the code you can ensure that you did not break anything.

Rails tests can also simulate browser requests without or with javascript and thus you can test your application's response without having to test it through your browser.

Introduction to Testing
-----------------------

### Setup for Testing 

Rails creates a `test` directory for you. If you list the contents of this directory you see:

```bash
$ ls -F test
controllers/    helpers/        mailers/        test_helper.rb
fixtures/       integration/    models/
```

The `models`, `controllers`, `mailers` and `helpers` directory 
hold tests for (surprise) models, controllers, mailers and view helpers respectively. 
These tests that are focussed on one single class are also called *unit tests*. 

The `integration` directory is meant to hold tests that test the 
whole system by accessing the app as a browser would.

Fixtures are a way of organizing test data; they reside in the `fixtures` directory.

The `test_helper.rb` file holds the default configuration for your tests.


### The Test Environment

By default, every Rails application has three environments: development, test, and production.

Each environment's configuration can be modified similarly. In this case, we can modify our test environment by changing the options found in `config/environments/test.rb` and we can add gems that are only used in testing by putting them in a test-section in the `Gemfile` like so:

```
# Gemfile
# use gem capybara only in test environment:
group :test do
  gem 'capybara'
end
```

### Write one Test

When you use the scaffold generator it will create
basic tests and fixtures for you:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

The default test stub in `test/models/article_test.rb` looks like this:

```ruby
require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

A line by line examination of this file will help get you oriented to Rails testing code and terminology.

```ruby
require 'test_helper'
```

By requiring this file, `test_helper.rb` the default configuration to run our tests is loaded. You will include this with all the tests you write.

```ruby
class ArticleTest < ActiveSupport::TestCase
```

The `ArticleTest` class defines a _test case_ because it inherits from `ActiveSupport::TestCase`, which
in turn inherits from `Minitest::Test`. 
Inside this class you will define the tests, either by
giving them a method name beginning with `test_` (case sensitive) or
by using this syntax:

```ruby
test "the truth" do
  assert true
end
```

Which is approximately the same as writing this:

```ruby
def test_the_truth
  assert true
end
```

Next, let's look at our first assertion:

```ruby
assert true
```

An assertion is a line of code that evaluates an object (or expression) for expected results. For example, an assertion can check:

* does this value equal that value?
* is this object nil?
* does this line of code throw an exception?
* is the user's password longer than 5 characters?

Every test must contain at least one assertion, with no restriction as to how many assertions are allowed. Only when all the assertions are successful will the test pass.

Here an example of a useful test: It checks that
a new article does not have an empty or nil title:

```ruby
test "new article has default title" do
  a = Article.new
  assert a.title.length > 3
end
```


### Running Tests

To run all the tests for your project use `rails test`.

```bash
$ rails test
Run options: --seed 8625

# Running:

........

Finished in 0.498780s, 16.0391 runs/s, 28.0685 assertions/s.

8 runs, 14 assertions, 0 failures, 0 errors, 0 skips
```

Every dot stands for one test that ran through sucessfully.


To see how a test failure is reported, you can add a failing test:

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save
end
```

If you run this newly added test the result might look like this:

```bash
$ rails test
Run options: --seed 33837

# Running:

........F

Finished in 0.492655s, 18.2684 runs/s, 30.4473 assertions/s.

  1) Failure:
ArticleTest#article_should_not_save_article_without_title [test/models/article_test.rb:10]:
Expected true to be nil or false

9 runs, 15 assertions, 1 failures, 0 errors, 0 skips
```

In the output, `F` denotes a failure. You can see the corresponding trace shown under `1)` along with the name of the failing test. The next few lines contain the stack trace followed by a message that mentions the actual value and the expected value by the assertion. The default assertion messages provide just enough information to help pinpoint the error. To make the assertion failure message more readable, provide a message, as shown here:

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save, "Saved the article without a title"
end
```

Running this test shows the friendlier assertion message:

```bash
  1) Failure:
test_should_not_save_article_without_title(ArticleTest) [test/models/article_test.rb:6]:
Saved the article without a title
```

Now to get this test to pass we can add a model level validation for the _title_ field.

```ruby
class Article < ActiveRecord::Base
  validates :title, presence: true
end
```

Now the test should pass. Verify this by actually running the test!  

Now, if you noticed, we first wrote a test which fails for a desired
functionality, then we wrote some code which adds the functionality and finally
we ensured that our test passes. This approach to software development is
referred to as
[_Test-Driven Development_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment).

#### What an error looks like

To see how an error gets reported, here's a test containing an error:

```ruby
test "should report error" do
  # some_undefined_variable is not defined elsewhere in the test case
  some_undefined_variable
  assert true
end
```

Now you can see even more output in the console from running the tests:

```bash
$ rails test
.....E...

Finished tests in 0.030974s, 32.2851 tests/s, 0.0000 assertions/s.

  1) Error:
test_should_report_error(ArticleTest):
NameError: undefined local variable or method `some_undefined_variable' for #<ArticleTest:0x007fe32e24afe0>
    test/models/article_test.rb:10:in `block in <class:ArticleTest>'

10 tests, 10 assertions, 0 failures, 1 errors, 0 skips
```

Notice the 'E' in the output. It denotes a test with error.

NOTE: The execution of each test method stops as soon as any error or an
assertion failure is encountered. But the test suite continues with the next
test. All test methods are executed in random order. 

When a test fails you are presented with the corresponding backtrace. By default
Rails filters that backtrace and will only print lines relevant to your
application. Read the backtrace!


If you want to ensure that an exception is raised 
you can use `assert_raises` like so:

```ruby
test "should report error" do
  assert_raises(NameError) do
    # some_undefined_variable is not defined elsewhere 
    some_undefined_variable
  end
end
```

This test should now pass.

### Available Assertions

You have seen some assertions above.

Here's an extract of the assertions you can use with
[`Minitest`](https://github.com/seattlerb/minitest), the default testing library
used by Rails. The `[msg]` parameter is an optional string message that is only
displayed if the test fails.  It is available in all assertions, but only shown in
the first one here.  For most assertions there is a simple negation `assert` and `assert_not`, `assert_equal` and
`assert_no_equal`, and so on. 

| Assertion                                                        | Purpose |
| ---------------------------------------------------------------- | ------- |
| `assert( test, [msg] )`                                          | Ensures that `test` is true.|
| `assert_not( test )`                                      | Ensures that `test` is false.|
| `assert_equal( expected, actual )`                        | Ensures that `expected == actual` is true.|
| `assert_same( expected, actual )`                         | Ensures that expected and actual are the exact same object.|
| `assert_nil( obj )`                                       | Ensures that `obj.nil?` is true.|
| `assert_empty( obj )`                                     | Ensures that `obj` is `empty?`.|
| `assert_match( regexp, string )`                          | Ensures that a string matches the regular expression.|
| `assert_no_match( regexp, string )`                       | Ensures that a string doesn't match the regular expression.|
| `assert_includes( collection, obj )`                      | Ensures that `obj` is in `collection`.|
| `assert_in_delta(expectated,actual,delta)`            | Ensures that the numbers `expectated` and `actual` are within `+/-delta` of each other.|
| `assert_raises( exception ){ block }`         | Ensures that the given block raises the given exception.|
| `assert_instance_of( class, obj )`                        | Ensures that `obj` is an instance of `class`.|
| `assert_kind_of( class, obj )`                            | Ensures that `obj` is an instance of `class` or is descended from it.|
| `assert_respond_to( obj, symbol )`                        | Ensures that `obj` responds to `symbol`, for example because it implements a method by that name or inherits one. |

The above are a subset of assertions that minitest supports. For an exhaustive &
more up-to-date list, please check
[Minitest API documentation](http://docs.seattlerb.org/minitest/), specifically
[`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html).

Because of the modular nature of the testing framework, it is possible to create your own assertions. In fact, that's exactly what Rails does. It includes some specialized assertions to make your life easier.

### Testing a Controller

To activate controller test add to your Gemfile:

```
group :development, :test do
  gem 'rails-controller-testing'
end
```

Testing the controller _without_ testing the view or the
models at the same time is quite tricky.  You should test for things such as:

* was the web request successful?
* was the user redirected to the right page?
* was the user successfully authenticated?
* was the correct object stored in the response template?
* was the appropriate message displayed to the user in the view?

In a controller test you can use the methods `get`, `post`, and so on
to call action in the controller with certain http methods and parameters.

In this example the `create` action of the article controller is called by
sending a post request to articles_url. 
The params hash is set up with key `article[title]` and value `some title`:

```
post articles_url, params: { article: { title: 'some title' } }
```
This example just shows `params`, you can also set:

* `headers` a hash of HTTP Request headers 
* `env` a hash of environment variables
* `xhr` true or false to make this an AJAX request or not
* `as` to request a content type, for example `as: :json`

After the request you get the result in three hashes:

* `session` 
* `flash`
* `cookies`

Rails adds some custom assertions for controllers.
You can see them at work in the tests created by scaffold:

`assert_response`  checks the status code of the HTTP response generated
by the controller:

```
# test/controller/articles_controller_test.rb
test "should get new" do
  get :new
  assert_response :success
end
```

`assert_difference` checks a value before and after
a block of code is run, to make sure that the value changed
by one:

```
test "should create article" do
  assert_difference('Article.count') do
    post :create, params: { article: { title: 'some title' } }
  end
end
```

`assert_redirect` makes sure the controller returns
a HTTP redirect header to the appropriate url:

```
test "should destroy article" do
  assert_difference('Article.count', -1) do
    delete :destroy, params: { id: 1 }
  end

  assert_redirected_to articles_path
end
```

The Test Database
-----------------

Just about every Rails application interacts heavily with a database and, 
as a result, your tests will need a database to interact with as well. 
To write efficient tests, you'll need to understand how to set up 
this database and populate it with sample data.

The database for each environment is configured in `config/database.yml`.

A dedicated test database allows you to set up and interact with test data in 
isolation. This way your tests can mangle test data with confidence, 
without worrying about the data in the development or production databases.


### Maintaining the test database schema

In order to run your tests, your test database will need to have the current
structure. The test helper checks whether your test database has any pending
migrations. If so, it will try to load `db/schema.rb`
into the test database. If migrations are still pending, an error will be
raised. Usually this indicates that your schema is not fully migrated. Running
the migrations against the development database (`rails db:migrate`) will
bring the schema up to date.

NOTE: If existing migrations required modifications, the test database needs to
be rebuilt. This can be done by executing `rails db:test:prepare`.

### Test Data with Fixtures

For good tests, you'll need to give some thought to setting up test data.
In Rails, the most simple way of doing this is by defining and customizing fixtures. 
Fixtures are database independent and written in YAML. There is one file per model.

You'll find fixtures under your `test/fixtures` directory. When you run 
`rails generate model` to create a new model, 
Rails automatically creates fixture stubs in this directory.

#### YAML

YAML-formatted fixtures are a human-friendly way to describe 
your sample data. These types of fixtures have the **.yml** file extension (as in `users.yml`).

Here's a sample YAML fixture file:

```yaml
# lo & behold! I am a YAML comment!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Systems development

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: guy with keyboard
```

Each fixture is given a name followed by an indented list of colon-separated 
key/value pairs. Records are typically separated by a blank line. 
You can place comments in a fixture file by using the # character in the first column.

If there are [associations](/rails_database_and_model.html#1-n-associations) 
between models, you can 
simply refer to the fixture in a related model using its name.
Here's an example with a `belongs_to`/`has_many` association:

```yaml
# In fixtures/categories.yml
about:
  name: About This Site

# In fixtures/articles.yml
one:
  title: Welcome to Rails!
  body: Hello world!
  category: about
```

Notice the `category` key of the `one` article found in `fixtures/articles.yml` 
has a value of `about`. This tells Rails to load the 
category `about` found in `fixtures/categories.yml`.

NOTE: For associations to reference one another by name, 
you cannot specify the `id:` attribute on the associated fixtures. 
Rails will auto assign a primary key to be consistent between runs. 
For more information on this association behavior please read 
the [Fixtures API documentation](http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### Fixtures with ERB

ERB allows you to embed Ruby code. The YAML fixture format is pre-processed with 
ERB when Rails loads fixtures. This allows you to use Ruby to help you generate 
some sample data. For example, the following code generates a thousand users:

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### Using fixtures in Tests

The data defined by the fixture files will be available 
in your tests as Active Record objects. For example:

```ruby
# in test/models/user_test.rb
# the User object for the fixture named david
users(:david)

# turn the property for david called id
users(:david).id

# one can access methods available on the User class
users(:david).partner.email
```

To get multiple fixtures at once, you can pass in a list of fixture names. For example:

```ruby
# this will return an array containing the fixtures david and steve
users(:david, :steve)
```

Integration Testing with Capybara and Webkit
-------------------

Integration test are used to test that the various parts of your application interact correctly
to implement features. You can use a software "browser" to test your app. Rails 5 comes
with built in integration tests, that simulate a browser without javascript. These
are stored in the folder `test/integration/`

We will use the gem `capybara` and additionally the headless browser `webkit`
to write our integration tests.  This way we can test with javascript enabled
or disabled in our simulated browser.

# Gemfile
group :development, :test do
  gem 'minitest-rails-capybara'
  gem 'capybara-webkit'
end

# test_helper.rb
require "minitest/rails/capybara"
Capybara.javascript_driver = :webkit
```

The integration tests written with capybara are also called feature
tests (and stored in the 'test/features' directory).
Minitest and Capybara provide a generator to create a test skeleton for you.

```bash
$ rails generate minitest:feature add_a_star_to_a_user
      create  test/features/add_a_star_to_a_user_test.rb
```

Here's what a freshly-generated feature test looks like:

```ruby
require 'test_helper'

class AddAStarToAUserTest < Capybara::Rails::TestCase
  test "sanity" do
    visit root_path
    assert_content page, "Hello World"
    refute_content page, "Goobye All!"
  end
end
```

`visit` is capybaras method for making a HTTP request just as the browser would.


#### Testing a form 

Integration tests are black box tests: we only interact with the
app through the web browser, and have no "inside knowledge" about the app.  

Some helper methods:

```
click_link('id-of-link')
click_link('Link Text')
find('#navigation').click_link('Home')

click_button('Save')
find("#overlay").find_button('Send').click

fill_in('First Name', with: 'John')
choose('A Radio Button')
check('A Checkbox')
uncheck('A Checkbox')
attach_file('Image', '/path/to/image.jpg')
select('Option', :from => 'Select Box')

all('a').each { |a| ... a[:href] ... }

within("li#employee") do
  fill_in 'Name', :with => 'Jimmy'
  ...
end
```

Some assertions:

```
assert_content('foo')
assert_text('bar')
assert_selector('table tr')
assert_button('save')
assert_checked_field('newsletter')
assert_link('more')
```


#### Testing Javascript

Testing with an embedded browser like webkit makes
it possible to test javascript and AJAX behaviour.

```
test "page contains text generated by JavaScript" do
  Capybara.current_driver = Capybara.javascript_driver
  visit root_path
  assert_content page, "Dynamic Text"
end
```

While developing your test it might be helpful
to *see* what the invisible browser is doing.
You can save a screenshot to a file automatically:

```
  save_screenshot('tmp/list_of_users_screenshot.png', :full => true)
```

For debugging purposes it might also be useful
to see if anything was written to the javascript console.
The console is available through `page.driver.console_messages`.
But it is probably best not to write tests that expect certain
console output.

Further Reading
---------------

* [A Guide to Testing Rails Applications](http://guides.rubyonrails.org/testing.html) - also contains an introduction to testing routes, mailers, helpers, jobs and more in depth information on testing controllers
* [Fixtures API documentation](http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)
