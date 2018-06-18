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

Cross-Site Scripting (XSS)
---

> XSS flaws occur whenever an application includes untrusted data in a new web page without proper validation or escaping, or updates an existing web page with user-supplied data using a browser API that can create HTML or JavaScript. XSS allows attackers to execute scripts in the victim's browser which can hijack user sessions, deface web sites, or redirect the user to malicious sites. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A7-Cross-Site_Scripting_(XSS))


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

In the context of JSON you need to  use `json_escape`:


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

Using Components with Known Vulnerabilities
---

> Components, such as libraries, frameworks, and other software modules, run with the same privileges as the application. If a vulnerable component is exploited, such an attack can facilitate serious data loss or server takeover. Applications and APIs using components with known vulnerabilities may undermine application defenses and enable various attacks and impacts. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A9-Using_Components_with_Known_Vulnerabilities)

Insufficient Logging&Monitoring
---

> Insufficient logging and monitoring, coupled with missing or ineffective integration with incident response, allows attackers to further attack systems, maintain persistence, pivot to more systems, and tamper, extract, or destroy data. Most breach studies show time to detect a breach is over 200 days, typically detected by external parties rather than internal processes or monitoring. [OWASP Wiki](https://www.owasp.org/index.php/Top_10-2017_A10-Insufficient_Logging%26Monitoring)


Cross Site Request Forgery (CSRF)
---

This security problem used to be No 8 on the list, but was no longer listed in the 2017.

> A CSRF attack forces a logged-on victim’s browser to send a forged HTTP request, including the victim’s session cookie and any other automatically included authentication information, to a vulnerable web application. This allows the attacker to force the victim’s browser to generate requests the vulnerable application thinks are legitimate requests from the victim. [OWASP Wiki](https://www.owasp.org/index.php/Top_10_2013-A8-Cross-Site_Request_Forgery_(CSRF))



Todo
----


# Security + Frameworks
* Backend Development 2
* OWASP Top 10
### Injection
### Cross Site Scripting (XSS)
* Authentifizierung und Session-Management
### Unsichere direkte Objektreferenzen
### Cross-Site Request Forgery (CSRF)
* Sicherheitsrelevante Fehlkonfiguration
* Kryptografisch unsichere Speicherung
* Mangelhafter URL-Zugriffsschutz
* Unzureichende Absicherung der Transportschicht
* Ungeprüfte Um- und Weiterleitungen
* Injection
* Injections + Frameworks
* Rails + SQL Injection
* Warning von Brakeman:
* # possible SQL injection in food_controller.rb

* whereTextGroceries = "groceries.category_id = "+params[:cat]
*  
* @groceries = Supermarket
*   .select('supermarkets.*, supermarkets.name as pickup, supermarkets.id as supermarktLink')
*   .joins(:groceries)
*   .select('groceries.*, groceries.name as foodname')
*   .where(whereTextGroceries)


* Injection + Rails
* Project.where("name = '#{params[:name]}'")
* **' OR 1 --**
* SELECT * FROM projects WHERE name = '' OR 1 --'

* **') UNION SELECT id,login AS name,password AS description,1,1,1 FROM users –**
* SELECT * FROM projects WHERE (name = '') UNION
*   SELECT id,login AS name,password AS description,1,1,1 FROM users --'






* Injection + Rails
* Ruby on Rails has a built-in **filter** for special SQL characters, which will escape quotes, NULL character and line breaks. 
* Using Model.find(id) or Model.find_by_some thing(something) automatically applies this countermeasure. 

* Injection + Rails
* in SQL fragments, especially in conditions fragments, you can pass an array to sanitize tainted strings:
* Model.where("login = ? AND password = ?", entered_user_name, entered_password).first
* The sanitized versions of the variables in the second part of the array replace the question marks. 
* Or you can pass a hash for the same result:
* Model.where(login: entered_user_name, password: entered_password).first

* Rails+PG: Prepared Statements
* Prepared Statements are enabled by default on PostgreSQL. You can disable prepared statements by setting prepared_statements to false:
<p class="p18">Production:
  adapter: postgresql
  prepared_statements: false</p>
* If enabled, Active Record will create up to 1000 prepared statements per database connection by default. To modify this behavior you can set statement_limit to a different value:
<p class="p18">Production:
  adapter: postgresql
  statement_limit: 200</p>
* The more prepared statements in use: the more memory your database will require. If your PostgreSQL database is hitting memory limits, try lowering statement_limit or disabling prepared statements.
* Injections + Frameworks
* Rails + SQL Injection
* PHP + SQL Injection
* Injection + PHP
* Prepared Statements verwenden
<p class="p5">Falls die DB das nicht unterstützt:
Escaping</p>




* Injections + Frameworks
* Rails + SQL Injection
* PHP + SQL Injection
* MongoDB Injection
* MongoDB Injection
<p class="p19">SQL:
SELECT * FROM books WHERE ISBN = isbn_number;

SELECT * FROM books WHERE
   NOT(price = 1.99) AND price IS NOT NULL;</p>
<p class="p20">JS Query in Mongodb:
db.books.find( { ISBN: isbn_number } );

db.books.find( { $and: [
    { price: { $ne: 1.99 } },
    { price: { $exists: true } }
] } );
</p>
* Examples from 
* http://blog.securelayer7.net/mongodb-security-injection-attacks-with-php/


* MongoDB Injection with PHP v1
* $collection = $db-&gt;users;
* $cursor = $collection-&gt;find( array("id" =&gt; 5) );
* Foreach ($cursor as $document) {...




* $collection-&gt;find( PHP Array )
* Beware of automatic conversion of parameters into arrays
<p class="p25">$qry = array("id" =&gt; $_GET['u_id'])

array("id" =&gt; "5")
array("id" =&gt; array( "u_id" =&gt; "5" ))</p>

<p class="p5">Make sure you build your query for find
with only strings, not unkown data structures!</p>
* $id = ….. Make sure you only get one string
* $qry = array("id" =&gt; $id)



* MongoDB Injection with PHP v1
* $jsquery = "var data = db.users.findOne( {username: '$u_name', password: '$u_pass'}); return data;";
* $data = $db-&gt;execute( $jsquery );





* $db-&gt;execute( String with JS );
* Whitelist – if you can
<p class="p29">$u_name = preg_replace('/[^a-z0-9_]/i', '', $_GET['u_name']);
…</p>
* $jsquery = "var data = db.users.findOne( {username: '$u_name', password: '$u_pass'}); return data;";

* Escape String Separator with Slash
* …
* $u_pass = addslashes($_GET['u_pass']);
* $jsquery = "var data = db.users.findOne( {username: '$u_name', password: '$u_pass'}); return data;";





* Mongodb + mongoose
* Am JS Kongress 2016: Security Problem mit nicht gelöschtem Buffer, kann auf alte/fremde Daten zugreifen
* Damas noch keine Lösung?
* Avoiding Injection Flaws

* Avoid the interpreter entirely, or
* Use an interface that supports bind variables (e.g., prepared statements, or stored procedures),
* Bind variables allow the interpreter to distinguish between code and data
* Encode all user input before passing it to the interpreter
* Always perform ‘white list’ input validation on all user supplied input
* Always minimize database privileges to reduce the impact of a flaw

* Cross-Site Scripting Illustrated
* Cross-Site Scripting (XSS)
* Occurs any time…
* Raw data from attacker is sent to an innocent user’s browser
* Raw data…
* Stored in database
* Reflected from web input (form field, hidden field, URL, etc…)
* Sent directly into rich JavaScript client
* Virtually every web application has this problem
* Try this in your browser – javascript:alert(document.cookie)
* Typical Impact
* Steal user’s session, steal sensitive data, rewrite web page, redirect user to phishing or malware site
* Most Severe: Install XSS proxy which allows attacker to observe and direct all user’s behavior on vulnerable site and force user to other sites
* Cross Site Scripting + PHP
* **PHP ohne Framework**
* Richtig escapen mit htmlspecialchars, oder urlencode, oder json_encode, …
* PHP Befehl strip_tags ist zu schwach, statt dessen HTML Purifier verwenden
* Cross Site Scripting + ERB/Rails
* **Rails ERB**
<p class="p5">**&lt;%= @review.title %&gt;**
automatisch für HTML escaped</p>
<p class="p37">&lt;%= raw @user.formatted_profile %&gt;
wird nicht escaped!</p>
<p class="p37">Für Helper Methods, die sicherses html liefern: .html_save
module UserHelper
  # use like this:  &lt;%= camera_icon %&gt;
  def camera_icon
     '&lt;i class="fa fa-camera-retro"&gt;&lt;/i&gt;'.html_save
  end</p>
<p class="p38">HTML bauen, das  den input escaped, und den output als sicher markiert:
  # use like this: &lt;%= block_profile(@user) %&gt;
  def block_profile(user)
     content_tag :div, user.profile
  end
end</p>
* Cross Site Scripting + Handlebars
* **Handlebars: Escaping**
* **Handlebars: Helper**
* Handlebars HTML-escapes values returned by a **{{expression}}**. 
* If you don't want Handlebars to escape a value, use the "triple-stash", **{{{**. 
* **&lt;div class="entry"&gt;**
* **  &lt;h1&gt;{{title}}&lt;/h1&gt;**
* **  &lt;div class="body"&gt;**
* **    {{{body}}}**
* **  &lt;/div&gt;**
<p class="p18">**&lt;/div&gt;**
</p>
* **Handlebars.registerHelper('link', function(text, url) {**
* **  text = Handlebars.Utils.escapeExpression(text);**
* **  url  = Handlebars.Utils.escapeExpression(url);**
*
<p class="p39">**  var result = '&lt;a href="' + url + '"&gt;'
             + text + '&lt;/a&gt;';**</p>
*
* **  return new Handlebars.SafeString(result);**
* **});**

* Cross Site Scripting + Angular
* Angular treats all values as untrusted by default
* Sanitizes and escapes untrusted values
* Sanitization = Inspection of an untrusted value, turning it into a value that’s safe to insert into the DOM
* Angular sanitizes untrusted values for HTML, styles, and URLs
* &lt;p&gt;{{htmlSnippet}}&lt;/p&gt;
* &lt;p&gt;&lt;a [href]="dangerousUrl"&gt;Click me&lt;/a&gt;&lt;/p&gt;
* **Never generate template source code by concatenating user input and templates!**
* Avoiding XSS Flaws
* Eliminate Flaw
* Don’t include user supplied input in the output page
* Defend Against the Flaw
* Primary Recommendation: Output encode all user supplied input
* Safe Escaping Schemes in Various HTML Execution Contexts
* Broken Authentication and Session Management
* HTTP is a “stateless” protocol
* Means credentials have to go with every request
* Should use SSL for everything requiring authentication
* Session management flaws
* SESSION ID used to track state since HTTP doesn’t
* and it is just as good as credentials to an attacker
* SESSION ID is typically exposed on the network, in browser, in logs, …
* Beware the side-doors
<p class="p35">Change my password, remember my password, forgot my password,
secret question, logout, email address, etc…</p>
* Typical Impact
* User accounts compromised or user sessions hijacked

* Authentication and Session Management
* **Rails**
* **PHP**
* devise
* Wordpress
* ???
* Authentication and Session Management for Node.js 
* $ npm install passport
* The strategy (or strategies) have to be configured before authenticating requests.
* There are also some packages for using Facebook or Twitter etc.
* Authentication and Session Management for Node.js 
* You can use Express or Connect as middleware.

* Authentication and Session Management for Node.js 
* To authenticate a request use passport.athenticate() and define which strategy to use.
* Authentication and Session Management for Node.js 
* $ npm install passport-remember-me

* Add a new strategy for remember-me
* With a token.
* If the remember-me cookie is not managed
* carefully, it can cause severe security risks!


* COOKIES beschützen
* Achtung! Session_id ist genau so wertvoll wie das passwort!
* Session_id in der URL = schlechte idee
* Session_id im cookie = besser
* Dieses cookie braucht nicht in javascript lesbar sein
* HttpOnly
* Dieses cookie nur über HTTPS schicken:
* **secure** (cookie to only be transmitted over secure protocol as https)

* Avoiding Broken Authentication and Session Management
* Verify your architecture
* Authentication should be simple, centralized, and standardized
* Use the standard session id provided by your container
* Be sure SSL protects both credentials and session id at all times

* Verify the implementation
* Forget automated analysis approaches
* Check your SSL certificate
* Examine all the authentication-related functions
* Verify that logoff actually destroys the session
* Use OWASP’s WebScarab to test the implementation

* Insecure Direct Object References
* How do you protect access to your data?
<p class="p35">This is part of enforcing proper “Authorization”, along with
A7 – Failure to Restrict URL Access</p>
* A common mistake …
* Only listing the ‘authorized’ objects for the current user, or
* Hiding the object references in hidden fields
* **… and then not enforcing these restrictions on the server side**
* This is called presentation layer access control, and doesn’t work
* Attacker simply tampers with parameter value
* Typical Impact
* Users are able to access unauthorized files or data

* Insecure Direct Object References Illustrated
* Attacker notices his acct parameter is 6065
* She modifies it to a nearby number
*     ?acct=6066
* Attacker views the victim’s account information
* Rails: cancancan
* In der View:
* &lt;% if can? :update, @article %&gt;
*   &lt;%= link_to "Edit", edit_article_path(@article) %&gt;
* &lt;% end %&gt;
* In the Controller:
* def show
*   @article = Article.find(params[:id])
*   authorize! :read, @article
* end

* Avoiding Insecure Direct Object References
* Eliminate the direct object reference
* Replace them with a temporary mapping value (e.g. 1, 2, 3)







* Validate the direct object reference
* Verify the parameter value is properly formatted
* **Verify the user is allowed to access the target object**
* Query constraints work great!
* Verify the requested mode of access is allowed to the target object (e.g., read, write, delete)

* Use UUID as Primary Key
* Instead of serial/autocincrement  use of UUID

* **Postgresql use an UUID**:

* Within the database using the extension **pgcrypto** (or **uuid-ossp**)

* CREATE EXTENSION pgcrypto; 
* CREATE TABLE snw.contacts( id UUID PRIMARY KEY DEFAULT **gen_random_uuid()**,name TEXT, email TEXT );

* INSERT INTO snw.contacts (name,email) VALUES 
* ('Dr Nic Williams','drnic'), 
* ('Brian Mattal','brian');

* SELECT:
* 0d60a85e-0b90-4482-a14c-108aea2557aa | Dr Nic Williams | drnic 
* 39240e9f-ae09-4e95-9fd0-a712035c8ad7 | Brian Mattal    | brian

* **MySQL use an UUID:**
* uuid();   //Returns a 36 character varchar 
* Use UUID as Primary Key: Rails
<p class="p62">**Using UUID in RAILS with a POSTGRESQL Database:****
**</p>
* **Enable UUID‘s for Rails:**
*
* rails g migration enable_uuid_extension

* **In the generated migration enable ‘uuid-ossp‘ extension:**

<p class="p63">**class *EnableUuidExtension ***&lt; ***ActiveRecord***::***Migration***[5.0]
  **def ***change
    *enable_extension **'uuid-ossp'
  end
end**</p>
*
* Use UUID as Primary Key: Rails
* **In config/application.rb:**

<p class="p6">config.generators **do **|*g*|
  *g*.orm **:active_record**, **primary_key_type**: **:uuid
end**</p>
*
* This automatically adds id: :uuid to create_table in all future migrations!

<p class="p6">**class *CreateBooks ***&lt; ***ActiveRecord***::***Migration***[5.0]
  **def ***change
    create_table ***:books**, **id**: **:uuid do **|*t*|
      *t*.*string ***:title
      ***t*.timestamps
    **end
  end
end**</p>
<p class="p6">**
select * from books:**</p>
* 23dc0413-f9b3-4679-bc1d-2fe2d1b09330 | Harry Potter | 2017-06-06 15:14:12.247507 | 2017-06-06 15:14:12.247507
* Cross Site Request Forgery (CSRF)
* Cross Site Request Forgery
* An attack where the victim’s browser is tricked into issuing a command to a vulnerable web application
* Vulnerability is caused by browsers automatically including user authentication data (session ID, IP address, Windows domain credentials, …) with each request
* Imagine…
* What if a hacker could steer your mouse and get you to click on links in your online banking application?
* What could they make you do?
* Typical Impact
* Initiate transactions (transfer funds, logout user, close account)
* Access sensitive data
* Change account details

* CSRF Illustrated
* "Harmlose" Links können POSTs sein
* &lt;a href="http://www.harmless.com/" onclick="
*   var f = document.createElement('form');
*   f.style.display = 'none';
*   this.parentNode.appendChild(f);
*   f.method = 'POST';
*   f.action = 'http://www.example.com/account/destroy';
*   f.submit();
*   return false;"&gt;To the harmless survey&lt;/a&gt;

* Javascript Same-Origin policy
* Wenn jedes Javascript HTTP Requests zu jedem Server senden könnte...
* Deswegen gibt es die "Same Origin Policy"
* Javascript von example.com
* Kann XHR zu example.com machen

<p class="p3">XSS +
Javascript Same-Origin policy</p>
* ACHTUNG!
* Javascript von example.com
* Kann XHR zu example.com machen

* Um so wichtiger ist es zu verhindern, dass attacker JS in meine seite example.com einfügen können!

* CSRF verhindern
* **Rails**
* **PHP**
* *use GET and POST appropriately*
* *A security token in non-GET requests will protect your application from CSRF*
* *Im application controller: *protect_from_forgery
* CSRF Token selbst bauen
* Wordpress

* **node.js?**
* Batteries not included!
* CSRF Token erzeugung als middleware
* Einfügen in jeden Form, AJAX Request:
<p class="p64">form(action='/form',method='post')
  input(type='hidden', name='_csrf', value=token)
  label(for='color') Color:
  input(type='text',name='color',size='50')
  button(type='submit') Save</p>
*
* NodeJS vs. CSRF
* Angular + Rails + CSRF
* CSRF Strategy:
* The application server sends a randomly generated authentication token in a cookie. The client code reads the cookie and adds a custom request header with the token in all subsequent requests. The server compares the received cookie value to the request header value and rejects the request if the values are missing or don't match.
* Angular's http has built-in support for the client-side half of this technique in its XSRFStrategy. The default CookieXSRFStrategy is turned on automatically. 
* gem 'angular_rails_csrf' sets this automatically
* Maßnahme
* Varianten zum abspeichern/übertragen von CSRF-Token:
* Default: Session bound (req.session)
* Optional: Cookie bound (default name: _csrf)
* - Cookie parser muss registriert werden

* References:
* https://github.com/expressjs/csurf
* http://www.insiderattack.net/2016/02/developing-secure-nodejs-applications.html
* http://expressjs.com/de/advanced/best-practice-security.html


* Security Misconfiguration
* Web applications rely on a secure foundation
* Everywhere from the OS up through the App Server
* Don’t forget all the libraries you are using!!
* Is your source code a secret?
* Think of all the places your source code goes
* **Security should not require secret source code**
* CM must extend to all parts of the application
* All credentials should change in production
* Typical Impact
* Install backdoor through missing OS or server patch
* XSS flaw exploits due to missing application framework patches
* Unauthorized access to default accounts, application functionality or data, or unused but accessible functionality due to poor server configuration

* Security Misconfiguration Illustrated
* Security Misconfiguration
* **Rails**
* **PHP**
<p class="p5">database.yml
nicht ins git!</p>
* secrets.yml
* So many secrets: datenbank passwörter, api keys,  ....

* Hardening php is hard!
* Security Misconfiguration
* **node**
* Snyc untersucht package.json auf bekannte security probleme

* MongoDB 2017
* 3.Jänner 2017: "An attacker going by the name of Harak1r1 is hijacking unprotected MongoDB databases, stealing and replacing their content, and asking for a Bitcoin ransom to return the data."
<p class="p64">{ "_id" : ObjectId("5859a0370b8e49f123fcc7da"),
 "mail" : "harak1r1@sigaint.org",
 "note" : "SEND 0.2 BTC TO THIS ADDRESS 13zaxGVjj9MNc2jyvDRhLyYpkCh323MsMq AND CONTACT THIS EMAIL WITH YOUR IP OF YOUR SERVER TO RECOVER YOUR DATABASE !" }</p>

* Avoiding Security Misconfiguration
* Verify your system’s configuration management
* Secure configuration “hardening” guideline
* Automation is REALLY USEFUL here
* Must cover entire platform and application
* Keep up with patches for ALL components
* This includes software libraries, not just OS and Server applications
* Analyze security effects of changes
* Can you “dump” the application configuration
* Build reporting into your process
* If you can’t verify it, it isn’t secure
* Verify the implementation
* Scanning finds generic configuration and missing patch problems
* Insecure Cryptographic Storage
* Storing sensitive data insecurely
* Failure to identify all sensitive data
* Failure to identify all the places that this sensitive data gets stored
* Databases, files, directories, log files, backups, etc.
* Failure to properly protect this data in every location
* Typical Impact
* Attackers access or modify confidential or private information
* e.g, credit cards, health care records, financial data (yours or your customers)
* Attackers extract secrets to use in additional attacks
* Company embarrassment, customer dissatisfaction, and loss of trust
* Expense of cleaning up the incident, such as forensics, sending apology letters, reissuing thousands of credit cards, providing identity theft insurance
* Business gets sued and/or fined

* Insecure Cryptographic Storage Illustrated
* Insecure Cryptographic Storage
* **Rails**
* **PHP**
* has_secure_password
* Rails schreibt manche Parameter (z.B. die mit Namen „password“) nicht ins Logfile.
<p class="p70">config.filter_parameters &lt;&lt;
      :password, :ccnumber</p>

* Avoiding Insecure Cryptographic Storage
* Verify your architecture
* Identify all sensitive data
* Identify all the places that data is stored
* Ensure threat model accounts for possible attacks
* Use encryption to counter the threats, don’t just ‘encrypt’ the data
* Protect with appropriate mechanisms
* File encryption, database encryption, data element encryption

* Use the mechanisms correctly
* Use standard strong algorithms
* Generate, distribute, and protect keys properly
* Be prepared for key change
* Verify the implementation
* A standard strong algorithm is used, and it’s the proper algorithm for this situation
* All keys, certificates, and passwords are properly stored and protected
* Safe key distribution and an effective plan for key change are in place 
* Analyze encryption code for common flaws

* Failure to Restrict URL Access
* How do you protect access to URLs (pages)?
<p class="p35">This is part of enforcing proper “authorization”, along with
A4 – Insecure Direct Object References</p>
* A common mistake …
* Displaying only authorized links and menu choices
* This is called presentation layer access control, and doesn’t work
* Attacker simply forges direct access to ‘unauthorized’ pages
* Typical Impact
* Attackers invoke functions and services they’re not authorized for
* Access other user’s accounts and data
* Perform privileged actions

* Failure to Restrict URL Access Illustrated
* Attacker notices the URL indicates his role
*     /user/getAccounts

* He modifies it to another directory (role)
*     /admin/getAccounts, or
*     /manager/getAccounts

* Attacker views more accounts than just their own

* Rails: Restrict URL 
* **before_action im Controller**
* Zugriffsrecht pro action festlegen
* Rails: Restrict URL 
* **cancan**
* Zugriffsrechte an einer zentralen Stelle setzen
* class Ability
* Im Controller abfangen
* load_and_authorize_resource
* In der action abfangen
* authorize! :read, @article
* Im Template verwenden
* &lt;% if can? :update, @article %&gt;
* Rails: Restrict URL 
* **Pundit mit **Policy-Classes
*  class PostPolicy
*   attr_reader :user, :post
*  
*   def initialize(user, post)
*     @user = user
*     @post = post
*   end
*  
*   def update?
*     user.admin? or not post.published?
*   end
* end
* Avoiding URL Access Control Flaws
* For each URL, a site needs to do 3 things
* Restrict access to authenticated users (if not public)
* Enforce any user or role based permissions (if private)
* Completely disallow requests to unauthorized page types (e.g., config files, log files, source files, etc.)

* Verify your architecture
* Use a simple, positive model at every layer
* Be sure you actually have a mechanism at every layer

* Verify the implementation
* Forget automated analysis approaches
* Verify that each URL in your application is protected by either
* An external filter, like Java EE web.xml or a commercial product
* Or internal checks in YOUR code – Use ESAPI’s isAuthorizedForURL() method
* Verify the server configuration disallows requests to unauthorized file types
* Use WebScarab or your browser to forge unauthorized requests



* Insufficient Transport Layer Protection
* Transmitting sensitive data insecurely
* Failure to identify all sensitive data
* Failure to identify all the places that this sensitive data is sent
* On the web, to backend databases, to business partners, internal communications
* Failure to properly protect this data in every location
* Typical Impact
* Attackers access or modify confidential or private information
* e.g, credit cards, health care records, financial data (yours or your customers)
* Attackers extract secrets to use in additional attacks
* Company embarrassment, customer dissatisfaction, and loss of trust
* Expense of cleaning up the incident
* Business gets sued and/or fined

* Insufficient Transport Layer Protection Illustrated
* Avoiding Insufficient Transport Layer Protection
* Protect with appropriate mechanisms
* Use TLS on all connections with sensitive data
* Individually encrypt messages before transmission
* E.g., XML-Encryption
* Sign messages before transmission
* E.g., XML-Signature

* Use the mechanisms correctly
* Use standard strong algorithms (disable old SSL algorithms)
* Manage keys/certificates properly
* Verify SSL certificates before using them
* Use proven mechanisms when sufficient
* E.g., SSL vs. XML-Encryption
* Unvalidated Redirects and Forwards
* Web application redirects are very common
* And frequently include user supplied parameters in the destination URL
* If they aren’t validated, attacker can send victim to a site of their choice
* Forwards (aka Transfer in .NET) are common too
* They internally send the request to a new page in the same application
* Sometimes parameters define the target page
* If not validated, attacker may be able to use unvalidated forward to bypass authentication or authorization checks
* Typical Impact
* Redirect victim to phishing or malware site
* Attacker’s request is forwarded past security checks, allowing unauthorized function or data access

* Unvalidated Redirect Illustrated
* Avoiding Unvalidated Redirects and Forwards
* There are a number of options
* Avoid using redirects and forwards as much as you can
* If used, don’t involve user parameters in defining the target URL
* If you ‘must’ involve user parameters, then either
* Validate each parameter to ensure its valid and authorized for the current user, or
* (preferred) – Use server side mapping to translate choice provided to user with actual target page
* Defense in depth: For redirects, validate the target URL after it is calculated to make sure it goes to an authorized external site
* Some thoughts about protecting Forwards
* Ideally, you’d call the access controller to make sure the user is authorized before you perform the forward (with ESAPI, this is easy)
* With an external filter, like Siteminder, this is not very practical
* Next best is to make sure that users who can access the original page are ALL authorized to access the target page.




See Also
--------

* [Rails Guide: Security](http://guides.rubyonrails.org/security.html)
* Tool: [loofah](https://github.com/flavorjones/loofah)
* Tool: [brakeman](https://github.com/presidentbeef/brakeman)
