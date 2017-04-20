Security
=======================

This guide will give you an introduction
to the security features included in ruby on rails,
how to use them, and how to mess up in spite of all the
help the framework is giving you

By referring to this guide, you will be able to:

* Use rails's security features 
* Appreciate how hard security is

TODO:

* rewrite example test for minitest


REPO: You can fork the [code of the example app](https://github.com/web-engineering/rails-example-security). his app is full of security holes. While reading this guide you should
work on the app and fix those holes one by one.


---------------------------------------------------------------------------




Don't display confidential data
-------------------------

Rails offers a lot of security features.  But all those clever features
cannot save you from yourself.  In the example app all the passwords
are displayed on "/users". No framework can prevent that!

![](images/security-password-shown.png)

Let's use this as an example of how to fix a security problem
once you've found it:  First we write a test for the problem: `rails g integration_test users`

``` ruby
require 'test_helper'

class UsersTest < ActionDispatch::IntegrationTest
  fixtures :users

  test 'users are listed publicly' do
    get '/users'
    assert_response :success
    assert_select 'td', users(:one).email
  end

  test 'users passwords are not shown publicly' do
    get '/users'
    assert_response :success
    assert_select 'td', { text: users(:one).password, count: 0 }, 'no table cell contains a password'
  end
end
```

When we run this test it fails, because right now passwords are displayed:

![](images/security-password-test-fails.png)

Now we change the view to not display the passwords any more. We can
run the test to make sure we succeeded.



See Also
--------

* [Rails Guide: Security](http://guides.rubyonrails.org/security.html)
* Tool: [loofah](https://github.com/flavorjones/loofah)
* Tool: [brakeman](https://github.com/presidentbeef/brakeman)
