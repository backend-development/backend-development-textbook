Rails: Advanced Models
=========================

Models are the basic classes of a Rails Project.  The
data is actually stored in a relational database.

After working through this guide you should

* be able to use polymorphic associations

Sources and Examples

* [polymophic miniblog](https://github.com/bjelline/rails-example-polymorphic-miniblog)

-------------------------------------------------------------


The Code Smell
------------

We will build a mini blog, where you can post
articles.  These articles should either take
a picture or a link as an attachment.

On way to model this is to have two associations
for the article:

    @@@ruby
    Article
      has_one :image
      has_one :link

but this will lead to very awkward code later on:
when displaying an article, we always have to ask: does
this article have an image?  does it have a link? ....
we will end up with lot's of conditional statements (if- or switch statements).


In object oriented programming, this is a code smell: [Switch Statements Smell](http://c2.com/cgi/wiki?SwitchStatementsSmell). 
It's an indicator that you should not work with a type, but with a class
[Replace Type Code With Class](http://c2.com/cgi/wiki?ReplaceTypeCodeWithClass)


And that's what we'll do.


Polymorphic Associations
-----------------



Using Polymorphic Associations in our example
-------------

### Set up the article

```shell
rails new miniblog
cd miniblog
rails g migration Article title text:text
rake db:migrate
```

### Set up the first Attachment

```shell
rails g migration LinkAttachment url
```

We are aiming for this association:

```ruby
class Article < ActiveRecord::Base
  attr_accessible :title, :text
  belongs_to :attachment, :polymorphic => true
end
class LinkAttachment < ActiveRecord::Base
  attr_accessible :url
  has_one :article, :as => :attachment
end
```
 
To model the association in the database, we need **two columns** in
the articles table: one for the foreign key, and one for the name
of the class:

```shell
rails g migration add_attachment_to_articles attachment_id:integer attachment_type
```

Now we can try out the association on the console: First we
create a LinkAttachment:

```ruby
irb(main):002:0> la = LinkAttachment.new( :url => "https://eff.org" )
=> #<LinkAttachment id: nil, url: "https://eff.org">
irb(main):004:0> la.save
   (0.1ms)  begin transaction
  SQL (11.2ms)  INSERT INTO "link_attachments" ("url") VALUES (?)  [["url", "https://eff.org"]]
   (0.9ms)  commit transaction
=> true
```

Then we get an Article, and associate it with the LinkAttachment.

```ruby
irb(main):005:0> a = Article.first
  Article Load (0.2ms)  SELECT "articles".* FROM "articles" LIMIT 1
=> #<Article id: 1, title: "Cool", attachment_id: nil, attachment_type: nil>
irb(main):006:0> a.attachment=link
=> #<LinkAttachment id: 1, url: "https://eff.org">
irb(main):007:0> a.save
 (0.1ms)  begin transaction
 (2.9ms)  UPDATE "articles" SET "attachment_id"=1, "attachment_type"='LinkAttachment' WHERE "articles"."id"=1
 (0.8ms)  commit transaction
=> true
```

As you can see, not only is the id of the LinkAttachment saved as a foreign key in the articles table,
also the class of the LinkAttachment is saved as a string in the
`attachment_type`  column.


### Show Attachments

How do we show the attachments, without going back to
switch statements?

The scaffold already generated views for the LinkAttachment,
but we will refactor that a bit, by using the new collection render in the
`index.html.erb`

```ruby
<h1>All Link Attachments</h1>

<%= link_to 'Create New Link attachment', new_link_attachment_path %>

<%= render @link_attachments %>
```

If we call render like this, there will be an implicit loop over
all the attachments, and the view `_link_attachments.html.erb` will be used
to display each one. We will keep this view very simple:

```ruby
<p><b>Link:</b> <%= link_to link_attachment.url, link_attachment.url %></p>
```

We can use the same partial to display an attachment as part
of the article views.

This example shows the `show` view:

```ruby
<p><b>Title:</b> <%= @article.title %> </p>
<%= render @article.attachment %>

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
```

The result will be:

```html
<p><b>Title:</b> Cooler </p>
<p><b>Link:</b> <a href="http://railscasts.com/">http://railscasts.com/</a></p>

<a href="/articles/2/edit">Edit</a> |
<a href="/articles">Back</a>
```

### Set Up the Second Attachment

The second attachment type has a few more properties:
it's a quote, with an author and an url for attribution.

```shell
rails g scaffold QuoteAttachment text:text author url
rake db:migrate
```

```ruby
class QuoteAttachment < ActiveRecord::Base
  attr_accessible :text, :author, :url
  has_one :article, :as => :attachment
end
```

We can set up the views the same as we did with LinkAttachment,
this time the important view is called ``_quote_attachment.html.erb``.

The aricle views don't need to be changed at all to display both quotes and links
as needed.

### Edit An Article with Attachment

Rails offer support for nested forms.
With `accepts_nested_attributes_for` in the model
we will be able to use the `fields_for` form builder.

We also have to add `attachment_attributes` to the accessible attributes of the
article:

```ruby
ass Article < ActiveRecord::Base
  attr_accessible :title, :attachment_attributes
  belongs_to :attachment, :polymorphic => true
  accepts_nested_attributes_for :attachment
end
```

Now we can use the `fields_for` builder in the edit view of the article:

```ruby
<%= form_for(@article) do |f| %>
  <div class="field"> <%= f.label :title %><br /> <%= f.text_field :title %> </div>
  
  <% if @article.attachment %>
    <%= f.fields_for :attachment do |builder| %>

      <div class="field">
        <%= builder.label :url %><br />
        <%= builder.text_field :url %>
      </div>
  
    <% end %>
  <% end %>

  <div class="actions"> <%= f.submit %> </div>
<% end %>
```

This form will send the parameters to the
update action of the article controller. In 
the controller, we find the following in the ``params`` hash:

```ruby
  params[:article][:title] = "How to learn rails",
  params[:article][:attachment_attributes][:url] = "http://railscasts.com/"
  params[:article][:attachment_attributes][:id] = 3
```

By the magic of nested forms this is all handled by one `update_attributes`
method:

```ruby
  @article.update_attributes(params[:article])
```

The method updates both the right attachments table and the articles table
as necessary:

```log
Started PUT "/articles/2" for 127.0.0.1 at 2013-01-19 13:51:44 +0100
Processing by ArticlesController#update as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"***",
    "article"=>{"title"=>"How to learn rails",
    "attachment_attributes"=>{"url"=>"http://railscasts.com/", "id"=>"3"}},
    "commit"=>"Update Article", "id"=>"2"}
  Article Load (0.1ms)  SELECT "articles".* FROM "articles" WHERE "articles"."id" = ? LIMIT 1  [["id", "2"]]
   (0.5ms)  begin transaction
  LinkAttachment Load (0.1ms)  SELECT "link_attachments".* FROM "link_attachments" WHERE "link_attachments"."id" = 3 LIMIT 1
   (1.9ms)  UPDATE "link_attachments" SET "url" = 'http://railscasts.com/', WHERE "link_attachments"."id" = 3
   (0.2ms)  UPDATE "articles" SET "title" = 'How to learn rails' WHERE "articles"."id" = 2
   (0.9ms)  commit transaction
Redirected to http://localhost:3000/articles/2
Completed 302 Found in 51ms (ActiveRecord: 4.6ms)
```

But when we built the form, we avoided the real problem:
we did not create the right fields for a LinkAttachment or a 
QuoteAttachment, we just added one field for the `url`, which both
attachments have in common.

For this to work, we - again - create a partial that is common
to all the attachments: `_fields.html.erb`.  The name of the
partial is the same, but the content is differnt.  For the
QuoteAttachment it contains three input fields, for the
LinkAttachment this will be less.

```ruby
    <div class="quote_attachment">
      <div class="field">
        <%= f.label :text %><br />
        <%= f.text_area :text %>
      </div>
      <div class="field">
        <%= f.label :author %><br />
        <%= f.text_field :author %>
      </div>
      <div class="field">
        <%= f.label :url %><br />
        <%= f.text_field :url %>
      </div>
    </div>
```

We can also use this partial inside the `_form.html.erb` partial
to avoid code duplication.

In the edit-view of article we include the partial like this:

```ruby
<%= f.fields_for :attachment do |builder| %>
  <%= render :partial => fields_partial_for( @article.attachment ), :locals => { :f => builder }  %>
<% end %>
```

But how do we construct the name of the partial?  This is handled
by a helper method `fields_partial_for` in app/helpers/application_helper.rb:

```ruby
  def fields_partial_for( o )
    "#{o.class.name.underscore}s/fields"
  end
```

given an object, this helper will take the objects class, turn
it into a string, and change it from CamelCase to snake_case, to
get to the write notation for the directory-name of the partial.

You can use the console to follow the steps:

```ruby
irb(main):058:0> o = Article.first.attachment
=> #<LinkAttachment id: 1, url: "http://railscasts.com/">
irb(main):059:0> o.class
=> LinkAttachment(id: integer, url: string)
irb(main):060:0> o.class.name
=> "LinkAttachment"
irb(main):061:0> o.class.name.underscore
=> "link_attachment"
```

We can now edit articles with no attachments as well as articles with
an attachment.

### Create an Article with Attachment

For creating an article we really need different
forms: for an article without an attachment, and for
each type of attachment:

![Three create forms for articles](images/polymorphic_create_form.png)

The form we created for editing is almost ready
to be used for creating. All we have to is create
a new Article with a new Attachement.

```ruby
  def new
    @article = Article.new

    if( params[:attachment] )
      @attachment= LinkAttachment.new
      @article.attachment = @attachment
    end
  end
```

But of course we don't always want a LinkAttachment,
we want to create an Object of the Class that was specified
in the parameter.  We can use the rails-method `constantize`
to get to the Class from the string.

```ruby
    if( params[:attachment] )
      @attachment= params[:attachment].constantize.new
      @article.attachment = @attachment
    end
```

But actually we don't want to accept just any parameter - we
want to make sure it's the name of one of the Attachment-Classes.
This decision should be made in just one place in our code.
We can do this in a Attachment-Class:


```ruby
class Attachment
  @@children = ["LinkAttachment", "QuoteAttachment"]

  def self.subclass( s )
    return s.constantize if @@children.include?( s )
    raise "#{s} is not a valid Attachment"
  end
end
```

Now we can create the attachment and thus display the
right form for inputting the attachment:

```ruby
  def new
    @article = Article.new

    if( params[:attachment] )
      @article.attachment= Attachment.subclass( params[:attachment] ).new
    end
  end
```

But when we send in the form, we get an error:

![Error](images/polymorphic_create_error.png)

Looking at the parameters this makes sense: there 
is no information about the type of the attachment.

In the `update` action this posed no problem - the information
about the type was already stored in the database.  But in the `create` action
we have to create the article and the attachment from scratch,
so we have to transmit the type from the new-form to the create action
in some way.

A simple solution is to add a hidden field for the
`attachment_type` in `app/view/article/_form.html.erb`:

```ruby
  <% if @article.attachment %>
    <%= f.hidden_field :attachment_type %>
    <%= f.fields_for :attachment do |builder| %>
      <%= render :partial => fields_partial_for(@article.attachment), 
                 :locals  => { :f => builder }  %>
    <% end %>
  <% end %>
```

Now we can adapt the create action to handle the
attachment first:

```ruby
  def create
    if  params[:article][:attachment_attributes] 
    and params[:article][:attachment_type]
      c = Attachment.subclass( params[:article][:attachment_type] )
      @attachment = c.create!( 
          params[:article][:attachment_attributes] )
      params[:article].delete( :attachment_attributes )
      params[:article].delete( :attachment_type )
    end

    @article = Article.new(params[:article])

    @article.attachment = @attachment unless @attachment.nil?

    ...
```

As a last step we can add links to the new-form:

```ruby
<%= link_to 'New Article', new_article_path %>
<% Attachment.all_subclasses.each do |subclass| %>
  |  <%= link_to "with #{subclass}", 
                 new_article_path( :attachment => subclass ) %>
<% end %>
```


