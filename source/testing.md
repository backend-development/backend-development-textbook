Getting Started with Testing in Rails
===========

This guide gives an introduction
to built-in mechanisms in Rails for testing your application.

After reading this guide, you will know:

- Rails testing terminology.
- How to write unit tests for your applications models and controllers
- How to write system tests for your application.

This guide is a shorter version of the offical
[Guide to Testing Rails Applications](https://guides.rubyonrails.org/testing.html).

REPO: Fork the [example app 'testing for stars'](https://github.com/backend-development/rails-example-testing-for-stars) and try out what you learn here.

-------------------------------------------------------------------------------


## Why Write Tests?

Rails makes it super easy to write your tests. It starts by producing skeleton test code while you are creating your models and controllers.

By running your Rails tests after every change in the code you can ensure that you did not break anything.

Rails tests can also simulate browser requests without or with javascript and thus you can test your application's response without having to test it through your browser.

## Setup

### Folders and Files

Rails creates a `test` directory for you. If you list the contents of this directory you will
find two files that hold the configuration for your tests:

- `test_helper.rb` global test configuration
- `application_system_test_case.rb` configure a browser for system test

and several directories:

The `models`, `controllers`, `mailers`, `channels`, and `helpers` directory
hold tests for (surprise) models, controllers, mailers, channels and view helpers respectively.
These tests that are focussed on one single class are also called _unit tests_.

The `integration` directory hold tests that exercise the whole Rails stack,
from HTTP Request through routes, controllers, down to models and back
up to the view. The only thing left out is the client side of your app: Javascript
cannot be tested here.

The `system` directory is meant to hold tests that test the
whole system by accessing the app with a browser, including running
the javascript.

Fixtures are a way of organizing test data; they reside in the `fixtures` directory.

### The Test Environment

By default, every Rails application has three environments: development, test, and production.

Each environment has a configuration file in `config/environments/`.
For the test environment the file is `config/environments/test.rb`.

In the Gemfile you can add gems that are only used in one environment
by putting them in a section like so:

```
# Gemfile
# use gem capybara only in test environment:
group :test do
  gem 'capybara', '~> 2.13'
end
```

### Write one Test

When you use a generator it will also create
basic tests and fixtures for you:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

§
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

§

```ruby
require 'test_helper'
```

By requiring the file `test_helper.rb` the default configuration to run our tests is loaded. You will include this with all the tests you write.

§

```ruby
class ArticleTest < ActiveSupport::TestCase
```

The `ArticleTest` class defines a _test case_ because it inherits from `ActiveSupport::TestCase`, which
in turn inherits from `Minitest::Test`.

§

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

§

Next, let's look at our first assertion:

```ruby
assert true
```

An assertion is a line of code that evaluates an expression for expected results.
`assert true` is always satisfied, so this test always passes.

§

In a real test an assertion can check many things:

- does this value equal that value?
- is this value nil?
- does this line of code throw an exception?
- is the user's password longer than 5 characters?

§

Every test must contain at least one assertion, with no restriction as to how many assertions are allowed. Only when all the assertions are successful will the test pass.

## Test Driven Development

Here an example of a useful test, written with
[_Test-Driven Development_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment).

Test Driven Development means:

1. Write a test - it fails - "RED"
2. Write some code to make the test pass - "GREEN"
3. Improve your code, but make sure the test still passes - "REFACTOR"

For this example I want to add a validation
to my article class to forbid very short or missing titles.

### Red

I start by writing this test:

```ruby
test "article title needs to be at least 3 characters long" do
  a = Article.new(title: 'x')
  assert_not article.save
end
```

§

To run all the tests for your project use `rails test`.

§

If you run the test above the result might look like this:

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

In the output, `F` denotes a failure. You can see the corresponding trace shown under `1)` along with the name of the failing test. The next few lines contain the stack trace followed by a message that mentions the actual value and the expected value by the assertion. The default assertion messages provide just enough information to help pinpoint the error.

### Green

Now to get this test to pass we can add a model level validation for the _title_ field.

```ruby
class Article < ApplicationRecord
  validates :title, length: { minimum: 3 }
end
```

Now the test should pass. Verify this by actually running the test!

```bash
$ rails test
Run options: --seed 8625

# Running:

........

Finished in 0.498780s, 16.0391 runs/s, 28.0685 assertions/s.

8 runs, 14 assertions, 0 failures, 0 errors, 0 skips
```

Every dot stands for one test that ran through sucessfully.

## Unit Tests

### What an error in you test looks like

An error is different from a failing test. An error
is a problem in your test code, not your application code.
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

Notice the 'E' in the output. It denotes a test with an error.

NOTE: The execution of each test method stops as soon as any error or an
assertion failure is encountered. But the test suite continues with the next
test. All test methods are executed in random order.

When a test fails you are presented with the corresponding backtrace. By default
Rails filters that backtrace and will only print lines relevant to your
application. Read the backtrace!

#### How to catch exceptions from your application code

If you want to ensure that an exception is raised
by your application code
you can use `assert_raises` like so:

```ruby
test "MyClass no longer implements @@counter, raises error" do
  assert_raises(NameError) do
    MyClass.counter
  end
end
```

### Available Assertions

You have seen some assertions above.

Here's an extract of the assertions you can use with
[`Minitest`](https://github.com/seattlerb/minitest), the default testing library
used by Rails. The `[msg]` parameter is an optional string message that is only
displayed if the test fails. It is available in all assertions, but only shown in
the first one here. For most assertions there is a simple negation `assert` and `assert_not`, `assert_equal` and
`assert_no_equal`, and so on.

| Assertion                                  | Purpose                                                                                                           |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------- |
| `assert( test, [msg] )`                    | Ensures that `test` is true.                                                                                      |
| `assert_not( test )`                       | Ensures that `test` is false.                                                                                     |
| `assert_equal( expected, actual )`         | Ensures that `expected == actual` is true.                                                                        |
| `assert_same( expected, actual )`          | Ensures that expected and actual are the exact same object.                                                       |
| `assert_nil( obj )`                        | Ensures that `obj.nil?` is true.                                                                                  |
| `assert_empty( obj )`                      | Ensures that `obj` is `empty?`.                                                                                   |
| `assert_match( regexp, string )`           | Ensures that a string matches the regular expression.                                                             |
| `assert_no_match( regexp, string )`        | Ensures that a string doesn't match the regular expression.                                                       |
| `assert_includes( collection, obj )`       | Ensures that `obj` is in `collection`.                                                                            |
| `assert_in_delta(expectated,actual,delta)` | Ensures that the numbers `expectated` and `actual` are within `+/-delta` of each other.                           |
| `assert_raises( exception ){ block }`      | Ensures that the given block raises the given exception.                                                          |
| `assert_instance_of( class, obj )`         | Ensures that `obj` is an instance of `class`.                                                                     |
| `assert_kind_of( class, obj )`             | Ensures that `obj` is an instance of `class` or is descended from it.                                             |
| `assert_respond_to( obj, symbol )`         | Ensures that `obj` responds to `symbol`, for example because it implements a method by that name or inherits one. |

The above are a subset of assertions that minitest supports. For an exhaustive &
more up-to-date list, please check
[Minitest API documentation](https://github.com/seattlerb/minitest#user-content-description), specifically
[`Minitest::Assertions`](https://docs.ruby-lang.org/en/2.1.0/MiniTest/Assertions.html).

Because of the modular nature of the testing framework, it is possible to create your own assertions. In fact, that's exactly what Rails does. It includes some specialized assertions to make your life easier.

### Better Asserstion

[better assertion with ramcrest](https://github.com/hamcrest/ramcrest)

### Testing a Model

Models are easy to test separately because they do not depend on
other code (most of the time). In Rails the tests for a model X
are found in `test/models/x_test.rb`.

All the examples shown so far are from model tests.
Below you can see what the a complete model test could look like.
There is a `setup` section that will be executed before
each test.

```ruby
# file test/models/course_test.rb
require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  setup do
    @course = courses(:one)
  end

  test "should not save new course without title" do
    course = Course.new
    assert_not course.save, "Saved new course without a title"
  end
  test "cannot save existing course after removing title" do
    @course.title = ''
    assert_not @course.save, "Saved existing course without a title"
  end
  test "Course no longer implements .counter, raises error" do
    assert_raises(NameError) do
      @course.counter
    end
  end
end
```

So is the model test a unit test? It only tests one unit
of source code that you have written. It also exercises ActiveRecord
and the test database. So you could argue that it is more
than just a unit test. But for now it is a near a unit test as
we can get. We will look at more [advanced testing](advanced_testing.html)
later one. There you will learn how to build tests that only
test one unit of code.

### Testing a Controller

Controller tests exercise several parts of the rails stack: routing, the controller, models, the test database. But they do try to keep
views out of the mix.

To activate controller test add to your Gemfile:

```
group :development, :test do
  gem 'rails-controller-testing'
end
```

Testing the controller _without_ testing the view
at the same time is quite tricky. You should test for things such as:

- was the web request successful?
- was the user redirected to the right page?
- was the user successfully authenticated?
- was the correct object sent to the view?

In a controller test you can use the methods `get`, `post`, and so on.
These will be handled by rails routing as usual, and end up
calling an action in the controller with certain parameters.

In this example the `create` action of the article controller is called by
sending a post request to articles_url.
The params hash is set up with key `article[title]` and value `some title`:

```
post articles_url, params: { article: { title: 'some title' } }
```

This example just shows `params`, you can also set:

- `headers` a hash of HTTP Request headers
- `env` a hash of environment variables
- `xhr` true or false to make this an AJAX request or not
- `as` to request a content type, for example `as: :json`
- `cookies` to set cookies included in the request

After the request you get the response and three hashes:

- `session`
- `flash`
- `cookies`

Rails adds some custom assertions for controllers.
You can see them at work in the tests created by scaffold:

`assert_response` checks the status code of the HTTP response generated
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
by one. This is often used when creating models:

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

## Test Data

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
# I am a YAML comment
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: systems development

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

The `category` key of the `one` article found in `fixtures/articles.yml`
has a value of `about`. This tells Rails to load the
category `about` found in `fixtures/categories.yml`.

NOTE: Do not specify the `id:` attribute in fixtures.
Rails will auto assign a primary key to be consistent between runs.
For more information on this association behavior please read
the [Fixtures API documentation](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

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

## Integration Tests

Integration tests are used to test that the various parts of your application interact correctly to implement features. Integration tests do not include the client side.

Here is a first example of an integration test:

```ruby
class PublicTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:one)
  end

  test 'Course page' do
    get course_path(@course, locale: 'en')

    assert_response :success
    assert_select 'h1 span.title', text: "Course #{@course.title}"
    assert_select '.calendar_section .button_to input'
    assert_match 'collect', css_select('div.calendar_section').text
    assert_match '2 entries found', css_select('div.calendar_section p').text
  end

  test 'Edit a Course is not available' do
    get edit_course_path(@course, locale: 'en')

    assert_response :found
  end
end
```

The first test ensures that a course can be displayed.
A get request is used to load the show action of the course controller.

The following five assertions concern the HTTP response and the DOM of the retuned
html document.

The second test ensures that a certain path (here: the edit action of the course
controller) is not available to a user who is not logged in. When getting
the URL we expect a redirection to happen. The response contains the "found" http status code.

Here are some tests for logged in users with admin powers:

```ruby
class AdminTest <  ActionDispatch::IntegrationTest
  setup do
    @course = courses(:one)
    @admin = users(:one)

    get root_url

    post "/login", params: { username: @admin.name,
      password: 'notneeded' }
    follow_redirect!
    follow_redirect!

    assert_equal 200, status
  end

  test 'Edit a Course is available' do
    get edit_course_path(@course, locale: 'en')

    assert_response :success
  end
end
```

In the setup method the we log in as user one, who has admin powers.
After that the edit action of the course
controller is available.

Both `assert_select` and `css_select` access the HTML document.
You can also access it directly as `document_root_element`.

Learn more about integration test:

- [Rails Guide on Testing](https://guides.rubyonrails.org/testing.html#integration-testing)
- [Rails API Documentation ActionDispatch::IntegrationTest](https://api.rubyonrails.org/v5.2.1/classes/ActionDispatch/IntegrationTest.html)

## System Tests with Selenium and a headless Browser

System test are used to test that the various parts of your application interact correctly
to implement features. You can use a real browser to test your app, including the client side javascript.

Rails 5 comes
with built in system tests. These
are stored in the folder `test/system/`

These tests take a lot more time to run than the unit test
and even the integration tests
discussed earlier. They are not included if you run `rails test`, you have
to start them separately with `rails test:system`.

We will use the gem `selenium-webdriver` and the headless browser firefox
to write our system tests.

```
# Gemfile
group :development, :test do
...
end

# test_helper.rb
...
```

You need to install the browser separately. On Mac you can do this
by using brew:

```
brew install geckodriver # for firefox
brew install chromedriver # for chrome
```

There is a generator to create a test skeleton for you.

```bash
$ rails generate test_unit:system add_a_star_to_a_user
      create  test/system/add_a_star_to_a_user_test.rb
```

Here's what a freshly-generated system test looks like:

```ruby
require 'test_helper'

class AddAStarToAUserTest < ApplicationSystemTestCase
  test "sanity" do
    visit root_path
    assert_content page, "Hello World"
    refute_content page, "Goobye All!"
  end
end
```

`visit` is capybaras method for making a HTTP request just as the browser would.

#### Testing a form

System tests are black box tests: we only interact with the
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
to _see_ what the invisible browser is doing.
You can save a screenshot to a file automatically:

```
  save_screenshot('tmp/list_of_users_screenshot.png', :full => true)
```

For debugging purposes it might also be useful
to see if anything was written to the javascript console.
The console is available through `page.driver.console_messages`.
But it is probably best not to write tests that expect certain
console output.

## Further Reading

- [better assertion with ramcrest](https://github.com/hamcrest/ramcrest)
- [A Guide to Testing Rails Applications](https://guides.rubyonrails.org/testing.html) - also contains an introduction to testing routes, mailers, helpers, jobs and more in depth information on testing controllers
- [Fixtures API documentation](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)
- [Observations running 2M headless Chrome sessions](https://news.ycombinator.com/item?id=17233371)
