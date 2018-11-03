Security
=======================

This guide will give you an introduction
to the security features included in ruby on rails,
how to use them, and how to mess up in spite of all the
help the framework is giving you

By referring to this guide, you will be able to:

* Use rails's security features 
* Appreciate how hard security is


REPO: You can fork the [code of the example app](https://github.com/backend-development/rails-example-security). his app is full of security holes. While reading this guide you should
work on the app and fix those holes one by one.


---------------------------------------------------------------------------


Later on this Guide will follow the OWASP Top 10 from 2017 to discuss
security features of Ruby on Rails. But first a word of warning:

Rails offers a lot of security features.  But all those clever features
**cannot save you from yourself**.  In the example app all the passwords
are displayed on "/users". If you as a programmer decide to do that, no framework can prevent it!

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


Injection
--------

> Injection flaws, such as SQL, NoSQL, OS, and LDAP injection, occur when untrusted data is sent to an interpreter as part of a command or query. The attacker's hostile data can trick the interpreter into executing unintended commands or accessing data without proper authorization. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A1-Injection)

### SQL Injection and ActiveRecord

ActiveRecord will protect against SQL-Injection if you use methods like `find` and `where` without string interpolation.
But if you do use string interpolation to build up SQL queries, you open up your application to injection attacks.


Here is an example that is vunerable:

```ruby
Project.where("name = '#{params[:name]}'")
```

If a malicious user enters `' OR 1 --` as the name parameter, the resulting SQL query will be:

```sql
SELECT * FROM projects WHERE name = '' OR 1 --'
```

The two dashes start a comment ignoring everything after it. So the query returns all records from the projects table including those blind to the user. This is because the condition is true for all records.


The following uses of ActiveRecord methods  are not susceptible to inejction:

```ruby
Thing.find(params[:id])
User.where("login = ? AND password = ?", entered_user_name, entered_password).first
Project.where(name: params[:name])
```

The methods  `connection.execute()` and  `Model.find_by_sql()` both take SQL strings
as arguments.  To use these savely you can apply  `sanitize_sql()` to user input before
you interpolate it into a SQL query.


ActiveRecord will use prepared statements by default, but you can [configure it](http://edgeguides.rubyonrails.org/configuring.html#configuring-a-postgresql-database) not to do that.

### Links

* [SQL Injection chapter](http://guides.rubyonrails.org/security.html#sql-injection) of the Rails Guide "Securing Rails Applications" 
* [rails-sqli.org](https://rails-sqli.org/)
* [brakeman will warn about possible sql injections](https://brakemanscanner.org/docs/warning_types/sql_injection/)





Broken Authentication
---

> Application functions related to authentication and session management are often implemented incorrectly, allowing attackers to compromise passwords, keys, or session tokens, or to exploit other implementation flaws to assume other users' identities temporarily or permanently. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A2-Broken_Authentication)


Rails comes with basic built in functionality to handle authentication:

* [has_secure_password](http://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password) adds methods to set and authenticate against a BCrypt password to a model.

For most real world projects you will be using a gem:

* [devise](https://github.com/plataformatec/devise) to handle typical authentication flows like confimation mail or blocking accounts
* [omniauth](https://github.com/omniauth/omniauth/wiki/List-of-Strategies) to use other authentication providers

We discussed using this in the chapter on [Rails Authentication](rails_authentication.html).


### well known passwords

Use the gem `pwned` to access an API that will tell you if a password is too common and has
been featured in password lists:

```ruby
# Gemfile
gem "pwned"
```



```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
 
  validates :password, not_pwned: true
end
```

[Blog article on pwned gem](https://www.twilio.com/blog/2018/03/better-passwords-in-ruby-applications-pwned-passwords-api.html)




Sensitive Data Exposure
---

> Many web applications and APIs do not properly protect sensitive data, such as financial, healthcare, and PII. Attackers may steal or modify such weakly protected data to conduct credit card fraud, identity theft, or other crimes. Sensitive data may be compromised without extra protection, such as encryption at rest or in transit, and requires special precautions when exchanged with the browser. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A3-Sensitive_Data_Exposure)


The OWASP advises: Determine the protection needs of data in transit and at rest. For example, passwords, credit card numbers, health records, personal information and business secrets require extra protection, particularly if that data falls under privacy laws, e.g. EU's General Data Protection Regulation (GDPR), or regulations, e.g. financial data protection such as PCI Data Security Standard (PCI DSS). 


### Encryption in the Database

In Rails you can use the [attr_encrypted gem](https://github.com/attr-encrypted/attr_encrypted) to encrypt certain attributes in the database transparently.  While choosing to encrypt at the attribute level is the most secure solution, it is not without drawbacks. Namely, you cannot search the encrypted data, and because you can't search it, you can't index it either. You also can't use joins on the encrypted data. 

### Removing from the Logfile

By default, Rails logs all requests being made to the web application.  You can _filter certain request parameters from your log files_ by appending them to `config.filter_parameters` in the application configuration. These parameters will be replaced by "[FILTERED]" in the log.

```ruby
# in  initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [:password]
```

Provided parameters will be filtered out by partial matching regular expression. Rails adds default `:password` in the appropriate initializer, which will take care of `password` and `password_confirmation`.


### Ensuring that HTTPS is used

In the appropriate environment(s) force ssl:


```ruby
# in config/environments/production.rb

# Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
config.force_ssl = true
```

This will do three things:

1. Redirect all http requests to their https equivalents.
2. Set secure flag on cookies [rfc 6265](https://tools.ietf.org/html/rfc6265#section-4.1.2.5) to tell browsers that these cookies must not be sent for http requests.
3. Add HSTS headers to response. [rfc 6797](https://tools.ietf.org/html/rfc6797)

See [this blog article](https://blog.bigbinary.com/2016/08/24/rails-5-adds-more-control-to-fine-tuning-ssl-usage.html) for more details on configuring this


XML External Entities (XXE)
---

> Many older or poorly configured XML processors evaluate external entity references within XML documents. External entities can be used to disclose internal files using the file URI handler, internal file shares, internal port scanning, remote code execution, and denial of service attacks. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A4-XML_External_Entities_(XXE))

A XEE vunerability in nokogiri was [fixed in 2014](https://github.com/sparklemotion/nokogiri/issues/693), but
another was [found in 2017, and is not completely fixed yet](https://snyk.io/blog/nokogiri-xxe-vulnerabilities/).

Broken Access Control
---

> Restrictions on what authenticated users are allowed to do are often not properly enforced. Attackers can exploit these flaws to access unauthorized functionality and/or data, such as access other users' accounts, view sensitive files, modify other users' data, change access rights, etc. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A5-Broken_Access_Control)

Use all lines of defence on the server to restrict access:

### remove unused routes

[rails_best_practices: Restrict auto-generated routes](https://rails-bestpractices.com/posts/2011/08/19/restrict-auto-generated-routes/)

### check user roles and premissions in every controller

The simplest way is to use `current_user` to control access to models.
Instead of simply loading data:

```ruby
@project = Project.find(params[:id])
```

Instead, _query the user's access rights, too_:

```ruby
@project = current_user.projects.find(params[:id])
```

For more complex setups with different roles that have different permissions
use a gem like `cancancan` which will let you [define access in a declarative way](https://github.com/CanCanCommunity/cancancan/wiki/defining-abilities) and give you an `authorize!` method for controllers:

```ruby
@project = Project.find(params[:id])
authorize! :read, @project
```

### use UUIDs instead of bigint as id

If you need to have a resource that is available to anyone with the URL (think google docs, doodle),
but do not want users to be able to enumerate all possible URLs:

```
http://my-schedule.at/calendar/17
http://my-schedule.at/calendar/18
http://my-schedule.at/calendar/19 ...
````

Instead of serial/autocincrement  use of UUID

In postgresql you can use the extentions **pgcrypto** or **uuid-ossp**

```sql
CREATE EXTENSION pgcrypto; 
CREATE TABLE calendar( id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT );

INSERT INTO calendar (name) VALUES 
('meeting on grdp'), 
('security audit');

SELECT * from calendar;
0d60a85e-0b90-4482-a14c-108aea2557aa | meeting on grdp
39240e9f-ae09-4e95-9fd0-a712035c8ad7 | security audit
```


Rails can handle all this for you:

```ruby
# in config/application.rb
config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
```

now your urls will be harder to enumerate:


```
http://my-schedule.at/calendar/0d60a85e-0b90-4482-a14c-108aea2557aa
http://my-schedule.at/calendar/39240e9f-ae09-4e95-9fd0-a712035c8ad7 ...
````



### set CORS for your API

Browsers restrict cross-origin HTTP requests initiated by scripts. For example, **XMLHttpRequest** and the **Fetch API** follow the same-origin policy. This means that a web application using those APIs can only request HTTP resources from the same origin the application was loaded from, unless the response **from the other origin** includes the right CORS headers.

![cors principle](images/cors_principle.png)

If you want to make your API available to frontends on other origins you
can use the `rack-cors` gem:


```ruby
# Gemfile
gem 'rack-cors'
```

The configuration is done in an initializer:


```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:3000', '127.0.0.1:3000', 'https://my-frontend.org'
    resource '/api/v1/*',
      methods: %i(get post put patch delete options head),
      max_age: 600
  end

  allow do
    origins '*'
    resource '/public/*', headers: :any, methods: :get
  end  
end
```

* [MDN: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
* [rack-cors](https://github.com/cyu/rack-cors)


Security Misconfiguration
---

> Security misconfiguration is a result of insecure default configurations, incomplete or ad hoc configurations, open cloud storage, misconfigured HTTP headers, and verbose error messages containing sensitive information. Not only must all operating systems, frameworks, libraries, and applications be securely configured, but they must be patched/upgraded in a timely fashion. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A6-Security_Misconfiguration)

This is espacially relevent if you are running your own virtual machine: 

* upgrade the operating system, apply security patches
* remove unused components, e.g. a wordpress installation you no longer need
* upgrade ruby after [security problems are fixed](https://www.ruby-lang.org/en/news/2018/03/28/unintentional-file-and-directory-creation-with-directory-traversal-cve-2018-6914/)


### Use Environment Variables

The files `config/database.yml` and `config/secrets.yml` should not be added
to the repository - unless you extract out all the secrets into environment
variables (as a [12 factor app](https://12factor.net/config))

```
# in config/database.yml

default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # http://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: myapp_development

test:
  <<: *default
  database: myapp_test

production:
  <<: *default
  database: myapp_production
  username: myapp
  password: <%= ENV['MYAPP_DATABASE_PASSWORD'] %>
```


### Handling Secrets and Credentials


Rails 5 generates a `config/credentials.yml.enc` to store third-party credentials
within the repo. This is only viable because Rails encrypts the file with a master
key that's generated into a version control ignored `config/master.key` — Rails
will also look for that key in `ENV["RAILS_MASTER_KEY"]`. Rails also requires the
key to boot in production, so the credentials can be read.

To edit stored credentials use `bin/rails credentials:edit`.

By default, this file contains the application's
`secret_key_base`, but it could also be used to store other credentials such as
access keys for external APIs.

The credentials added to this file are accessible via `Rails.application.credentials`.
For example, with the following decrypted `config/credentials.yml.enc`:

    secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
    some_api_key: SOMEKEY

`Rails.application.credentials.some_api_key` returns `SOMEKEY` in any environment.

If you want an exception to be raised when some key is blank, use the bang
version:

```ruby
Rails.application.credentials.some_api_key! # => raises KeyError: :some_api_key is blank
```



Cross-Site Scripting (XSS)
---

> XSS flaws occur whenever an application includes untrusted data in a new web page without proper validation or escaping, or updates an existing web page with user-supplied data using a browser API that can create HTML or JavaScript. XSS allows attackers to execute scripts in the victim's browser which can hijack user sessions, deface web sites, or redirect the user to malicious sites. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A7-Cross-Site_Scripting_(XSS))


### Use a Content Security Policy (CSP)

[MDN: CSP](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)

In Rails 5.2 you dan configure a
[Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)
for your application in an initializer. You can configure a global default policy and then
override it on a per-resource basis.

Example global policy:

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, 'https://code.jquery.com'
  policy.font_src    :self, 'https://fonts.gstatic.com'
  policy.img_src     '*'
  policy.object_src  :none
  policy.script_src  :self, 'https://code.jquery.com'
  policy.style_src   :self, 'https://fonts.googleapis.com'

  # Specify URI for violation reports
  policy.report_uri "/csp-violation-report-endpoint"
end
```

To handle the violation reports you need to set up a model, controller and route
[as described here](https://bauland42.com/ruby-on-rails-content-security-policy-csp/#cspviolationreports).

### Escape for the correct context:

erb automatically escapes for HTML:

```ruby
<%= @article.title %>   
```

This escaping is not apporpriate for attributes:

```ruby
<p class=<%= params[:style] %>...</p>
```

An attacker can insert a space into the style parameter like so: `x%22onmouseover=javascript:alert('hacked')`

To construct HTML Attributes that are properly escaped
it is easiest to use view helpers like `tag` and `content_tag`:


```ruby
<%= content_tag :p, "...", class: params[:style]  %>
```

In the context of JSON you need to  use `json_encode`:


```ruby
<script>
  var userdata = <%= raw json_encode(@stuff.to_json) %>
</script>
```

When building a JSON API use `jbuilder` or `active_model_serializers` as described in [chapter APIs](/apis.html#rendering-json).


See [XSS in the brakeman documentation](https://brakemanpro.com/2017/09/08/cross-site-scripting-in-rails)

Insecure Deserialization
---

> Insecure deserialization often leads to remote code execution. Even if deserialization flaws do not result in remote code execution, they can be used to perform attacks, including replay attacks, injection attacks, and privilege escalation attacks. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A8-Insecure_Deserialization)

Brakeman will warn about [Unsafe Deserialization](https://brakemanscanner.org/docs/warning_types/unsafe_deserialization/index.html)

Using Components with Known Vulnerabilities
---

> Components, such as libraries, frameworks, and other software modules, run with the same privileges as the application. If a vulnerable component is exploited, such an attack can facilitate serious data loss or server takeover. Applications and APIs using components with known vulnerabilities may undermine application defenses and enable various attacks and impacts. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A9-Using_Components_with_Known_Vulnerabilities)


There are several tools that check for vulnerabilities in dependencies:

* [bundle audit](https://github.com/rubysec/bundler-audit)  will read the  Gemfile.lock, looking for gem versions with vulnerabilities reported in the [Ruby Advisory Database](https://github.com/rubysec/ruby-advisory-db).
* [snyk](https://snyk.io/) works for ruby and javascript (and more languages).

When using script-tags to include javascript (e.g. jquery, bootstrap from a cdn)
use Subresource Integrity checks to prevent [man in the middle attacks](https://security.stackexchange.com/questions/72652/javascript-injection-using-man-in-the-middle-attack?newreg=81c460e021c04123883661e86b95d14f#answer-72661) using your javascript.

```
<script
        src="https://code.jquery.com/jquery-3.3.1.min.js"
        integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
        crossorigin="anonymous"></script>
```

(This example from jquery also includes the CORS attribte `crossorigin` set to `anonymous`.
This way no user credentials will every be sent to `code.jquery.com`).


* Report: [Comcast uses MITM javascript injection to serve unwanted ads and messages](https://www.privateinternetaccess.com/blog/2016/12/comcast-still-uses-mitm-javascript-injection-serve-unwanted-ads-messages/)
* MDN: [Subresource Integrity - SRI](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity)



Insufficient Logging&Monitoring
---

> Insufficient logging and monitoring, coupled with missing or ineffective integration with incident response, allows attackers to further attack systems, maintain persistence, pivot to more systems, and tamper, extract, or destroy data. Most breach studies show time to detect a breach is over 200 days, typically detected by external parties rather than internal processes or monitoring. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A10-Insufficient_Logging%26Monitoring)


This is really outside the scope of the backend framework.  


Cross Site Request Forgery (CSRF)
---

This security problem used to be No 8 on the list, but was no longer listed in the 2017.

> A CSRF attack forces a logged-on victim’s browser to send a forged HTTP request, including the victim’s session cookie and any other automatically included authentication information, to a vulnerable web application. This allows the attacker to force the victim’s browser to generate requests the vulnerable application thinks are legitimate requests from the victim. [OWASP Wiki](https://www.owasp.org/index.php/Top_10_2013-A8-Cross-Site_Request_Forgery_(CSRF))

First use GET and POST appropriately. Secondly, a security token in non-GET requests will protect your application from CSRF. Rails can handle this for you:

To protect against all other forged requests, we introduce a _required security token_ that our site knows but other sites don't know. We include the security token in requests and verify it on the server. This is a one-liner in your application controller, and is the default for newly created Rails applications:

```ruby
# in app/controller/application_controller.rb

protect_from_forgery with: :exception
```

This will automatically include a security token in all forms and Ajax requests generated by Rails. If the security token doesn't match what was expected, an exception will be thrown.

By default, Rails includes an [unobtrusive scripting adapter](https://github.com/rails/rails/blob/master/actionview/app/assets/javascripts),
which adds a header called `X-CSRF-Token` with the security token on every non-GET
Ajax call. Without this header, non-GET Ajax requests won't be accepted by Rails.
When using another library to make Ajax calls, it is necessary to add the security
token as a default header for Ajax calls in your library. 

Note that cross-site scripting (XSS) vulnerabilities bypass all CSRF protections. XSS gives the attacker access to all elements on a page, so they can read the CSRF security token from a form or directly submit the form.






See Also
--------

* [Rails Guide: Security](http://guides.rubyonrails.org/security.html)
* Tool: [loofah](https://github.com/flavorjones/loofah)
* Tool: [brakeman](https://github.com/presidentbeef/brakeman)
