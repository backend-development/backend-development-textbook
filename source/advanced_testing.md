# Advanced Testing

This guide will show you new ways of testing.
By referring to this guide, you will be able to:

- Understand test doubles
- Write unit tests with rspec
- Write integration tests with capybara
- Manipulate time in your tests
- Stub out calls to Web Services efficiently
- Test the javascript frontend of your app

---

## rspec

Rspec is the second testing framework that is commonly used
with Ruby on Rails projects. According to [ruby-toolbox.com](https://www.ruby-toolbox.com/categories/testing_frameworks)
it is used more often than the (built in) Minitest.

Rspec replaces minitest in all aspects of rails, including in scaffolds.

The first things you hav to know to get started:

- tests are found in `spec/*` (not `test/*`)
- to run one test use `rspec <filename>` or `rspec <filename>:<linenumber>` on the command line
- to run all tests use `rake spec`

(yes, sometimes you need the `r` in rspec, and other times you leave it out.)

### A simple spec

A file can contain multiple test. You use `describe` and `it` to
structure the file. The arguments for `describe` and `it` are
used to describe the test in case of failure:

```ruby
describe Game do
  describe "#score" do
    it "returns 0 for all gutter games" do
      game = Game.new
      20.times { game.roll(0) }
      game.score.should == 0
    end
  end
end
```

The message when this test fails reads:

```ruby
Failures:

  1) Game#score returns 0 for all gutter games
     Failure/Error: game.score.should == 0
       expected: 0
            got: 1 (using ==)
     # ./x_spec.rb:15:in `block (3 levels) in <top (required)>'
```

It is a convention to actually use the Class under test as
the argument of `describe`.

Inside the test you can use ruby and rails. Instead of minitest's assertions
you formulate expectations with "should" (outdated) or "expect" (current):

```ruby
game.score.should == 0
expect(game.score).to eq(0)
```

There are two ways of writing matchers:

```ruby
foo.should == bar
foo.should eq(bar)       expect(foo).to eq(bar)
foo.should_not eq(bar)   expect(foo).not_to eq(bar)
foo.should be < 10       expect(foo).to be < 10

"a string".should_not =~ /a regex/
expect("a string").not_to match(/a regex/)

lambda { do_something }.should raise_error(SomeError)
expect { something }.to raise_error(SomeError)
```

### Example Model Spec

```ruby
describe Post do
  context "with 2 or more comments" do
    it "orders them in reverse chronologically" do
      post = Post.create!
      comment1 = post.comments.create!(:body => "first comment")
      comment2 = post.comments.create!(:body => "second comment")
      post.reload.comments.should == [comment2, comment1]
    end
  end
end
```

### Example Feature Spec

```ruby
feature "Widget management" do
  scenario "User creates a new widget" do
    visit "/widgets/new"
    fill_in "Name", :with => "My Widget"
    click_button "Create Widget"
    page.should have_text("Widget was created.")
  end
end
```

### Kinds of Tests

- Model specs
- Controller specs
- View specs
- Helper specs
- Mailer specs
- Routing specs
- Request specs
- Feature specs

## Cucumber

![](images/cucumber-1.png)

![](images/cucumber-2.png)

### Step Definitions

the magic behind cucumber:

```ruby
Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    Movie.create( movie )
  end
end
Then /^the director of "([^"]*)" should be "([^"]*)"$/ do |title, director|
  m = Movie.find_by_title( title )
  m.should_not be_nil
  m.director.should == director
end
```

## Test Doubles

According to Meszaros(2007)

- **Test stub** provide canned answers to calls made during the test
- **Mock object** used for verifying "indirect output" of the tested code, by first defining the expectations before the tested code is executed
- **Test spy** used for verifying "indirect output" of the tested code, by asserting the expectations afterwards, without having defined the expectations before the tested code is executed
- **Fake object** used as a simpler implementation, e.g. using an in-memory database in the tests instead of doing real database access

## Testing Web Servcies

VCR

## Testing Time

```ruby
describe "sets done_at" do
  t = Todoitem.create!( :text => "write" )
  t.done = true
  t.save!
  t.reload
  t.done_at.should == Time.now
end
```

![time fail](images/timefail-1.png)

![time fail](images/timefail-2.png)

### First solution: write your own matcher:

```ruby
# in your test:
t.done_at.should be_the_same_time_as( Time.zone.now )

# in spec_helper.rb:
RSpec::Matchers.define :be_the_same_time_as do |expected|
  match do |actual|
    expected.to_i == actual.to_i
  end
  failure_message_for_should do |actual|
    "expected that #{actual} (#{actual.to_i} in seconds) would be a the same as #{expected}  (#{expected.to_i} in seconds)"
  end
end
```

![](images/timefail-3.png)

### Second Solution: Timecop

```ruby
it "sets done_at" do
    t = Todoitem.create!( :text => "write" )
       Timecop.freeze do
       t.done = true
       t.save!
       t.reload
       t.done_at.should == Time.now
    end
end
```

## Testing Javascript

![](images/jasmine.png)

![](images/phantomjs.png)

### Phantom Example

```javascript
var page;
page = require("webpage").create();
page.open("http://localhost:3000", function(status) {
  var string;
  string = page.evaluate(function() {
    return $("h1").text();
  });
  console.log("Title: " + string);
  return phantom.exit();
});
```

```javascript
var page;
page = require("webpage").create();
page.open("http://localhost:3000", function(status) {
  var string;
  string = page.evaluate(function() {
    return $("h1").text();
  });
  console.log("Title: " + string);
  return phantom.exit();
});
```

### Phantom in rspec

with capybara and poltergeist

## Example App

Clone [this app](https://github.com/web-engineering/rails-example-test-the-todo) and try out your new testing strategies!

![screenshot example app](images/sample-app-todolist.png)
