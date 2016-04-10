Testing with RSpec
=======================

This guide will give you an introduction
to rspec, an alternative testing syntax for ruby on rails.
By referring to this guide, you will be able to:

* Write rspec tests for your models
* Write rspec + capybara acceptance tests

---------------------------------------------------------------------------

A word of warning
----------

There was a change in the organization of tests into
folder from rspec 1 to rspec 2.  So you might find
what is at first glance conflicting information on the web.

We will be using rspec 2 and capybara.  Find the installation
instructions on [rspecs homepage](https://github.com/rspec/rspec-rails).


Behaviour Driven Development (BDD)
------

BDD is a "top down" approach: you start out with a feature
that has actual value to the end user. to start building
this feature you

* first write an acceptance test for the whole feature
* this test will fail, because you haven't written any code to fulfill it yet
* then you think about how you would implement this feature, which smaller units of you code will have to do what
* for each unit:
 * you write the unit test
 * this test will fail,  because you haven't written any code to fulfill it yet
 * then you implement what is necessary to fulfill the test, until it passes
 * if the feature still fails, you go back to working on the next unit
* finally the feature passes

and you're done.







