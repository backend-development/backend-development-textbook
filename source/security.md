Security
========

This guide will give you an introduction
to some security aspects of backend and fullstack frameworks

---------------------------------------------------------------------------------------

## Where to learn about security

* To get a first impression learn about the [OWASP Top 10](https://owasp.org/www-project-top-ten/).
* For a real world project, follow the [OWASP Application Security Verification Standard 4.0.2](https://github.com/OWASP/ASVS/blob/master/4.0/OWASP%20Application%20Security%20Verification%20Standard%204.0.2-de.pdf).
* For configuring your web server follow [mozillas web security guidelines](https://infosec.mozilla.org/guidelines/web_security.html)


## Injection

> Injection flaws, such as SQL, NoSQL, OS, and LDAP injection, occur when untrusted data is sent to an interpreter as part of a command or query. The attacker's hostile data can trick the interpreter into executing unintended commands or accessing data without proper authorization. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A1-Injection)

If you use your ORM correctly you should be save. But make sure to find out
what you ORM does or does not do!





### SQL Injection and ActiveRecord

A good ORM like ActiveRecord will protect against SQL-Injection if used correctly.
For ActiveRecord: if you use the methods `find` or `where` without string interpolation
Rails will turn them into prepared statements - since [Rails 3.1, 2011](https://patshaughnessy.net/2011/10/22/show-some-love-for-prepared-statements-in-rails-3-1).

You can see this in the Rails console: The SQL statements contain placeholders $1, $2, and the
bound values are supplied separately:

```ruby
Project.find(42)
# SELECT  "projects".* FROM "projects" WHERE "projects"."id" = $1 LIMIT $2
# [["id", 42], ["LIMIT", 1]]

Project.where(title: params[:title])
# SELECT "projects".* FROM "projects" WHERE "projects"."title" = $1
# [["title", "Marios World"]]

Project.where("publication_date > ?",  1.year.ago)
# SELECT "projects".* FROM "projects" WHERE (publication_date > '2018-06-03 12:15:54.952581')
```

§

But if you use string interpolation to build up SQL queries,
you open up your application to injection attacks. An example that is vunerable:

```ruby
@projects = Project.where("title = '#{params[:title]}'")
# SELECT "projects".* FROM "projects" WHERE (title = 'Marios World')
```

If a malicious user enters `' OR ''='` as the name parameter, the resulting SQL query is:

```sql
SELECT "projects".* FROM "projects" WHERE (title = '' OR ''='')
```

As you can see the SQL Fragment was incorporated into the SQL query before
the string was handed to ActiveRecord. The resulting query returns all records from the projects table.
This is because the condition is true for all records.


### Links

* [SQL Injection chapter](https://guides.rubyonrails.org/security.html#sql-injection) of the Rails Guide "Securing Rails Applications"
* [rails-sqli.org](https://rails-sqli.org/)
* [brakeman will warn about possible sql injections](https://brakemanscanner.org/docs/warning_types/sql_injection/)




Broken Authentication
---

> Application functions related to authentication and session management are often implemented incorrectly, allowing attackers to compromise passwords, keys, or session tokens, or to exploit other implementation flaws to assume other users' identities temporarily or permanently. [OWASP Wiki](https://owasp.org/www-project-top-ten/2017/A2_2017-Broken_Authentication)


You should check if your backend framework has the following features,
or if you need to add them through packages.

* passwords:
  * support for strong password hashing
  * support for rejecting known passwords (through [haveibeenpwned API](https://haveibeenpwned.com/API/v3))

### Authentication in Rails

Rails comes with basic built in functionality to handle authentication:

* [has_secure_password](https://api.rubyonrails.org/classes/ActiveModel/SecurePassword/ClassMethods.html#method-i-has_secure_password) adds methods to set and authenticate against a BCrypt password to a model.

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

### Testing

When implementing these features you can write integration tests to make
sure they actually work.

```
  test "can create user with password ljkw8723kjasf889r" do
    get "/sign_up"
    assert_response :success

    assert_difference('User.count',1) do
      post "/users", params: {
        user: {
          name:"Me Stupid",
          email:"peter@prayalot.com",
          password:'ljkw8723kjasf889r',
          homepage:'https://some.where'
        }
      }
    end
    assert_select 'span', text: 'has previously appeared in a data breach and should not be used', count: 0
    follow_redirect!

    assert_select 'li', text: /Me Stupid/
  end
```

Sensitive Data Exposure
---

> Many web applications and APIs do not properly protect sensitive data, such as financial, healthcare, and Peronally Identifiable Information ... Sensitive data may be compromised without extra protection, such as encryption at rest or in transit, and requires special precautions when exchanged with the browser. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A3-Sensitive_Data_Exposure)

§

The OWASP advises: Determine the protection needs of data **in transit** and **at rest**. For example, passwords, credit card numbers, health records, personal information and business secrets require extra protection, particularly if that data falls under privacy laws, e.g. EU's General Data Protection Regulation (GDPR), or regulations, e.g. financial data protection such as PCI Data Security Standard (PCI DSS).


You should check if your backend framework has the following features,
or if you need to add them through packages.

* Encryption in the Database
* keeping sensitive data from being logged
* ensuring that https is used


### Encryption in the Database

From Rails version 7 on [ActiveRecord offers encryption](https://edgeguides.rubyonrails.org/active_record_encryption.html). For older versions  you can use the [attr_encrypted gem](https://github.com/attr-encrypted/attr_encrypted) to encrypt certain attributes in the database transparently.

While choosing to encrypt at the attribute level is the most secure solution, it is not without drawbacks. Namely, you cannot search the encrypted data, and because you can't search it, you can't index it either. You also can't use joins on the encrypted data.

### Removing from the Logfile

By default, Rails logs all requests being made to the web application.  You can _filter certain request parameters from your log files_ by appending them to `config.filter_parameters` in the application configuration. These parameters will be replaced by "[FILTERED]" in the log.


```
Started POST "/user/sign_in" for 127.0.0.1 at 2021-01-05 08:46:01 +0100
Processing by Devise::SessionsController#create as HTML
  Parameters: {"utf8"=>"✓", "user"=>{"email"=>"brigitte.jellinek@fh-salzburg.ac.at", "password"=>"[FILTERED]", "remember_me"=>"1"}
In"}
```

```ruby
# in initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [:password]
```

Provided parameters will be filtered out by partial matching regular expression. Rails adds default `:password` in the appropriate initializer, which will take care of `password` and `password_confirmation`.


### Ensuring that HTTPS is used

In the appropriate environment(s) force ssl:


```ruby
# in config/environments/production.rb

# Force all access to the app over SSL,
# use Strict-Transport-Security, and use secure cookies.
config.force_ssl = true
```

This will do three things:

1. Redirect all http requests to their https equivalents.
2. Set secure flag on cookies [rfc 6265](https://tools.ietf.org/html/rfc6265#section-4.1.2.5) to tell browsers that these cookies must only be sent through https requests.
3. Add HSTS headers to response. [rfc 6797](https://tools.ietf.org/html/rfc6797)

See [this blog article](https://blog.bigbinary.com/2016/08/24/rails-5-adds-more-control-to-fine-tuning-ssl-usage.html) for more details on configuring this



Broken Access Control
---

> Restrictions on what authenticated users are allowed to do are often not properly enforced. Attackers can exploit these flaws to access unauthorized functionality and/or data, such as access other users' accounts, view sensitive files, modify other users' data, change access rights, etc. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A5-Broken_Access_Control)


As a programmer you need to

* remove unused routes
* check user roles and permissions in every route/controller/server component before data access
* use UUIDs instead of integers in URLs to avoid enumeration attacks
* set CORS to restrict access to your API

### remove unused routes

[rails_best_practices: Restrict auto-generated routes](https://rails-bestpractices.com/posts/2011/08/19/restrict-auto-generated-routes/)

### check user roles and permissions in every controller

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
use a gem like `cancancan` which will let you [define access in a declarative way](https://github.com/CanCanCommunity/cancancan/blob/develop/docs/Defining-Abilities.md#readme) and give you an `authorize!` method for controllers:

```ruby
@project = Project.find(params[:id])
authorize! :read, @project
```

### use UUIDs instead of bigint as id

In some circumstances you need to have a resource that is available
to anyone with the URL - think google docs or doodle.

But you do not want users to be able to enumerate all possible URLs:

```
https://my-schedule.at/calendar/17
https://my-schedule.at/calendar/18
https://my-schedule.at/calendar/19 ...
````

To avoid the enumeration attack you can switch from using serial/autocincrement as
the primary key in the database to using UUIDs.  Then the URLs will look like this:

```
https://my-schedule.at/calendar/0d60a85e-0b90-4482-a14c-108aea2557aa
https://my-schedule.at/calendar/39240e9f-ae09-4e95-9fd0-a712035c8ad7
https://my-schedule.at/calendar/a3240e9e-1209-4e95-9fd0-a712035c8ad4 ...
```

§

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

§

Rails can handle all this for you:

```ruby
# in config/application.rb
config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end
```

### set CORS for your API

Browsers restrict cross-origin HTTP requests initiated by scripts. For example, **XMLHttpRequest** and the **Fetch API** follow the same-origin policy. This means that a web application using those APIs can only request HTTP resources from the same origin the application was loaded from, unless the response **from the other origin** includes the right CORS headers.

![cors principle](images/cors_principle.png)

(Text and Image originally from [MDN](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS) by [many contributres](https://wiki.developer.mozilla.org/en-US/docs/Web/HTTP/CORS$history) is licensed under [CC BY-SA 2.5](https://creativecommons.org/licenses/by-sa/2.5/)

§

In the most simple case, when doing a cross-origin request:

* the client send a `Origin` header
* the server responds with a `Access-Control-Allow-Origin` header

for example:

```
GET /resources/data.json HTTP/1.1
Host: bar.other
Origin: https://foo.example

HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Content-Type: application/json
```

§

If a scripts tries to fetch a ressource cross-origin from server X and no
`Access-Control-Allow-Origin` Header
is set on server X, then the browser will throw an error and not
continue with the script:

```
fetch("https://iou-brigitte.herokuapp.com/users.json")
  .then(function(response) {
    return response.json();
  })
  .then(function(data) {
    console.log(data);
  });
```


![](images/cors-error.png)

§

After setting the right Headers for the HTTP Response,
the request goes through:

```
HTTP/1.1 200 OK
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET
```

![](images/cors-ok.png)

§

In Rails you
can use the `rack-cors` gem to set the Header in middleware:

```ruby
# Gemfile
gem 'rack-cors'
```

The configuration is done in an initializer:

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/*', headers: :any, methods: :get
  end

  allow do
    origins 'localhost:3000', '127.0.0.1:3000', 'https://my-frontend.org'
    resource '/api/v1/*',
      methods: %i(get post put patch delete options head)
  end
end
```

In this example get-requests are allowed for all origins,
while using the full api is only allowed for three specific domains.

§

- [MDN: CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [rack-cors](https://github.com/cyu/rack-cors)

Security Misconfiguration
---

> Security misconfiguration is a result of insecure default configurations, incomplete or ad hoc configurations, open cloud storage, misconfigured HTTP headers, and verbose error messages containing sensitive information. Not only must all operating systems, frameworks, libraries, and applications be securely configured, but they must be patched/upgraded in a timely fashion. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A6-Security_Misconfiguration)

This is especially relevant if you are running your own virtual machine:

- upgrade the operating system, apply security patches
- remove unused components, e.g. a wordpress installation you no longer need
- upgrade the interpreater after security problems are fixed, see [ruby](https://www.ruby-lang.org/en/news/), [node.js](https://nodejs.org/en/blog)

You should check if your backend framework has the following features,
or if you need to add them through packages:

- use of Environment Variables for passwords, api keys, etc.
- Storing Secrets in an encrypted file

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
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: myapp_development

test:
  <<: *default
  database: myapp_test

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

### Storing Secrets in an encrypted file

Rails 5.2 and later generates two files to handle credentials (passwords, api keys, ...):

- `config/credentials.yml.enc` to store the credentials within the repo
- `config/master.key` or `ENV["RAILS_MASTER_KEY"]` to read the encryption key from

The master key is never stored in the repo.

To edit stored credentials use `rails credentials:edit`.

By default, this file contains the application's
`secret_key_base`, but it could also be used to store other credentials such as
access keys for external APIs.

§

The credentials are accessible in
the running Rails app via `Rails.application.credentials`.

For example, with the following decrypted `config/credentials.yml.enc`:

    secret_key_base: 3b7cd727ee24e8444053437c36cc66c3
    some_api_key: 123454321

`Rails.application.credentials.some_api_key` returns `123454321` in any environment.

If you want an exception to be raised when some key is blank, use the bang
version:

```ruby
Rails.application.credentials.some_api_key!
# => raises KeyError: :some_api_key is blank
```

Cross-Site Scripting (XSS)
----

> XSS flaws occur whenever an application includes untrusted data in a new web page without proper validation or escaping, or updates an existing web page with user-supplied data using a browser API that can create HTML or JavaScript. XSS allows attackers to execute scripts in the victim's browser which can hijack user sessions, deface web sites, or redirect the user to malicious sites. [OWASP Wiki](<https://www.owasp.org/index.php/Top_10-2017_A7-Cross-Site_Scripting_(XSS)>)

You already know about escaping data when using it in HTML.

Your view layer probably does this automatically

The modern solution to XSS ist a [Content Security Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)(CSP)


### Escape for the correct context in Ruby on Rails

erb automatically escapes for HTML:

```ruby
<%= @article.title %>
```

This escaping is not apporpriate for attributes:

```ruby
<!-- DANGER, do not use this code -->
<p class=<%= params[:style] %> >...</p>
<!-- DANGER, do not use this code -->
```

An attacker could insert a space into the style parameter like so: `x%22onmouseover=alert('hacked')`
resulting in the following html

```html
<!-- DANGER, do not use this code -->
<p class=x onmouseover=alert('hacked') >...</p>
<!-- DANGER, do not use this code -->
```

To construct HTML Attributes that are properly escaped
it is easiest to use view helpers like `tag` and `content_tag`:

```ruby
<%= content_tag :p, "...", class: params[:style]  %>
```

When transferring data from the backend to the frontend
through JSON you need to use `json_encode` with the additional
option

```ruby
<script>
  const attributes = <%= raw json_encode(@attrs, escape_html_entities_in_json = true) %>
</script>
```

See [brakeman](https://brakemanscanner.org/docs/warning_types/cross_site_scripting_to_json/) for the rationale.

When building a JSON API use `jbuilder` or `active_model_serializers` as described in [chapter APIs](/apis.html#rendering-json).

### Escape for the correct context in React

JSX automatically escapes for html:

If you want to output a string that should be interpreted as HTML you need to use
[dangerouslySetInnerHTML](https://react.dev/reference/react-dom/components/common#common-props)


### Content Security Policy

It is either defined with the HTTP Header `Content-Security-Policy` or through
the `meta` tag.

```html
<meta
  http-equiv="Content-Security-Policy"
  content="default-src 'self'" />
```


The post basic policy would be

```
default-src 'self'
```

This policy will ensure that

1. all content to come from the site's own origin
2. inline javascript with `<script>` and `onevent` attributes cannot be used
3. dynamic code evaluation such as `eval`, `setImmediate` and `window.execScript` cannot be used

The first point is explicitly set by the directive. Point 2 and 3 are always in effect
when using CSP. You can explicitly allow `unsave-inline` and `unsave-eval`, if you want to
disable 2 and 3.


### configuring Policy for different resources

* style-src
* script-scr
* img-src
* font-src


### Content Security Policy in Rails


In Rails you can configure the Content Security Policy
for your application in an initializer.

Example global policy:

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src    :self, 'https://fonts.gstatic.com'
  policy.img_src     '*'
  policy.object_src  :none
  policy.script_src  :self, 'https://code.jquery.com'
  policy.style_src   :self, 'https://fonts.googleapis.com'

  # Specify URI for violation reports
  policy.report_uri "/csp-violation-report-endpoint"
end
```

This automatically forbids all 'unsave-inline' script: `<script>`-tags
in the html code and event-handler-attributes like `<button onclick=...>`.

To allow certain `<script>`-tags in your code you can give
them a "nonce":

```
<script nonce="2726c7f26c">
  var inline = 1;  // good javascript
</script>
```

This must be the same nonce given in the CSP:

```
Content-Security-Policy: script-src 'nonce-2726c7f26c'
```

Rails can generate separate nonces for separate sessions automatically,
see [the Rails Security Guide](https://guides.rubyonrails.org/security.html#adding-a-nonce).

If you want to handle violation reports, you need to set up a model, controller and route [as described here](https://bauland42.com/ruby-on-rails-content-security-policy-csp/#cspviolationreports).


Using Components with Known Vulnerabilities
----

> Components, such as libraries, frameworks, and other software modules, run with the same privileges as the application. If a vulnerable component is exploited, such an attack can facilitate serious data loss or server takeover. Applications and APIs using components with known vulnerabilities may undermine application defenses and enable various attacks and impacts. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A9-Using_Components_with_Known_Vulnerabilities)


In the last years security features have been incorporated in gem, npm, ....
Many, many malware packages are submitted to the repositories. Here an Example:

* [security audit of a npm package](https://socket.dev/npm/package/segment-bundle/files/6.6.9/package.json)


Before using a gem, look it up in the [ruby-toolbox](https://www.ruby-toolbox.com/)
and check if it is actively maintained and if there are better alternatives.

There are several tools that check for vulnerabilities in dependencies:

- [bundler-audit](https://www.ruby-toolbox.com/projects/bundler-audit) will read the Gemfile.lock, looking for gem versions with vulnerabilities reported in the [Ruby Advisory Database](https://github.com/rubysec/ruby-advisory-db).
- [snyk](https://snyk.io/) works for ruby and javascript (and more languages).

Use `bundle update --conservative gem_name` to safely update vulnerable dependencies.

When using script-tags to include javascript (e.g. bootstrap, react) from a cdn
use Subresource Integrity checks. This way, if a hacker manages to change
the script on the CDN your application will not be affected:

```
<script
  src="https://code.jquery.com/jquery-3.3.1.min.js"
  integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
  crossorigin="anonymous"></script>
```

(This example from jquery also includes the CORS attribte `crossorigin` set to `anonymous`.
This way no user credentials will every be sent to `code.jquery.com`).

- Report: [Comcast uses MITM javascript injection to serve unwanted ads and messages](https://www.privateinternetaccess.com/blog/2016/12/comcast-still-uses-mitm-javascript-injection-serve-unwanted-ads-messages/)
- MDN: [Subresource Integrity - SRI](https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity)


Cross Site Request Forgery (CSRF)
----

This security problem used to be No 8 on the list, but was no longer listed in the 2017.

> A CSRF attack forces a logged-on victim’s browser to send a forged HTTP request, including the victim’s session cookie and any other automatically included authentication information, to a vulnerable web application. This allows the attacker to force the victim’s browser to generate requests the vulnerable application thinks are legitimate requests from the victim. [OWASP](https://owasp.org/www-community/attacks/csrf)

First use GET and POST appropriately. Secondly, a security token in non-GET requests will protect your application from CSRF.



### CSRF and Rails

Rails can handle this for you

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

## See Also

- [Rails Guide: Security](https://guides.rubyonrails.org/security.html)
- Tool: [loofah](https://github.com/flavorjones/loofah)
- Tool: [brakeman](https://github.com/presidentbeef/brakeman)
