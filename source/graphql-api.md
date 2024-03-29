APIs
===========

After working through this guide you will:

- know about the thinking behind GraphQL APIs
- be able to configure your existing Rails App to offer a GraphQL API


-------------------------------------------------------------------------------


## API Styles

### What is an API?

API stands for "Application Programming Interface". It is a set of clearly defined methods
of communication with a software component. So the objects and methods exposed by a library
form an API.

In Web development the acronym API is most
commonly used when the software component in question runs on a different server on the
Internet and is accessed via HTTP.


### SOAP, REST and GraphQL

Currently three main API styles are used on the Web:

* SOAP, designed 1998 at Microsoft, uses XML and POST requests to make "remote procedure calls"
* REST, described in 2000, uses different HTTP Methods and Status Messages to access "resources"
* GraphQL, released 2015 by Facebook, uses POST requests, it's own query language and JSON

This Guide is concerned with GraphQL, there is a second guide for [REST](/rest-api.html). SOAP
is rearely offered with Rails, but there is a [soap client](https://github.com/savonrb/savon) in
ruby.

### API layer is a separate layer

Please note that any of the API styles can be used
with any backend, frontend, persistance layers:

* You can build a REST in front of a PHP backend using MongoDB as the database and use it from a frontend written with jQuery.
* You can build a GraphQL API for a Rails backend using MySQL as the database and build the frontend with React.

That's kind of the point of an API: to allow different technologies
on both sides of the API.


## GraphQL

REST and SOAP APIs are fixed interfaces: each api call has a fixed set of
arguments and returns a fixed data structure.  All decisions are made when
specifying the API.

GraphQL shifts some decisions to the client: through a Query Language the client
can request data in the specific shape it needs, within the limits that the
API sets.

### Query Language

A simple example with two models: a project has many URLs. when querying
through GraphQL you can request different attributes of both models:

![1:n relationship in the database](images/two-queries.gif)

Notice how the resulting JSON data mirrors the structure of the query.
The query language is used for both Queries (getting data) and Mutations (changing
data).

### Introspection and Playground

A GraphQL API can always be queried to give information
about the possible queries, mutations and types.  This is called
introspection.

The GraphQL Playground is a Web App that enables you to
make Queries and Mutations.  It uses introspection to display
documentation and to offer autocompletion:

<video controls autoplay>
  <source src="images/autocomplete.mov" type="video/quicktime" />
  <source src="images/autocomplete.mp4" type="video/mp4" />
  ![GraphQL Playground](images/graphql-playground.png)
</video>

###  Types

A GraphQL delivers JSON, which only has objects, arrays, strings, numbers and null
as types.  But GraphQL itself can build a more detailed type system and check
these types in queries and mutations.

### How the server handles the request

- parse the query
- validate with schema
- resolve data
- convert response to JSON

## Using Rails to build a GraphQL API

### Setup

To add a GraphQL API to an existing Rails app you need just two gems:

```
gem 'graphql'
group :development do
  gem 'graphql-rails-generators'
end
```

#### generator

The rest of the setup is handled by a generator added by the `graphql` gem:

```
rails generate graphql:install
       exist  app/graphql/types
      create  app/graphql/types/.keep
      create  app/graphql/portfolio_relaunch_schema.rb
      create  app/graphql/types/base_object.rb
      create  app/graphql/types/base_argument.rb
      create  app/graphql/types/base_field.rb
      create  app/graphql/types/base_enum.rb
      create  app/graphql/types/base_input_object.rb
      create  app/graphql/types/base_interface.rb
      create  app/graphql/types/base_scalar.rb
      create  app/graphql/types/base_union.rb
      create  app/graphql/types/query_type.rb
add_root_type  query
      create  app/graphql/mutations
      create  app/graphql/mutations/.keep
      create  app/graphql/mutations/base_mutation.rb
      create  app/graphql/types/mutation_type.rb
add_root_type  mutation
      create  app/controllers/graphql_controller.rb
       route  post "/graphql", to: "graphql#execute"
     gemfile  graphiql-rails
       route  graphiql-rails
Gemfile has been modified, make sure you `bundle install`
```

#### playground is available

After running bundle and restarting the server you can
access the graphql playground at `http://localhost:3000/graphiql`:
in the left pane you can enter a query, run it, and see the
result in the middle pane.  The right pane contains documentation
that was created automatically.

![GraphQL Playground](images/graphql-playground.png)

We have no Queries to run yet.


### Generating a Type from a Model

As a first step we can
use a generator to create a type from an existing model:

```
rails generate gql:model_type Project
      create  app/graphql/types/project_type.rb
```

Now we can edit the type to fit our needs, for example
we can remove attributes that should never be public:

```
module Types
  class ProjectType < Types::BaseObject
    field :id, GraphQL::Types::ID, null: false
    field :title, String, null: false
    field :publicationdate, GraphQL::Types::ISO8601Date, null: false
    field :membership, Int, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :slug, String, null: false
  end
end
```

### Defining a Query

The next level up we come to the query.  There is already
a dummy Query in `app/graphql/types/query_type.rb`

```
module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end
  end
end
```

#### Declare the Query and implement the resolver


We can replace this with a query that returns a list of all projects:

```
module Types
  class QueryType < Types::BaseObject
    field :all_projects, [ProjectType],
      null: false,
      description: "a list of all publicly visible projects"
    def all_projects
      Project.public.all
    end
  end
end
```

We can now run the query in the playground. Your query will be autocompleted.

<video controls autoplay>
  <source src="images/autocomplete.mov" type="video/quicktime" />
  <source src="images/autocomplete.mp4" type="video/mp4" />
  ![GraphQL Playground](images/graphql-playground.png)
</video>

#### Queries with arguments

If a query needs arguments you have do declare
them in the `fields` declaration and then handle
them in the method:

```
    field :project, ProjectType, null: true do
      argument :id, ID, required: true
    end
    def project(id:)
      Project.visible.find(id)
    end
```

### Relationships between models


#### Create type for a second model

![1:n relationship in the database](images/graphql-project-has-many-urls.png)

generate the UrlType automatically from the model:

```
module Types
  class UrlType < Types::BaseObject
    field :id, GraphQL::Types::ID, null: false
    field :title, String, null: true
    field :url, String, null: true
    field :url_type, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
  end
end
```

#### create queries for the second model


add the queries `all_urls` and `url` to  `app/graphql/types/query_type.rb`

now you can use those queries in the playground

#### add field for relationship to type


add the field `urls` to `app/graphql/types/project_type.rb`:

```
module Types
  class ProjectType < Types::BaseObject
    field :id, GraphQL::Types::ID, null: false
    field :title, String, null: false
    field :publicationdate, GraphQL::Types::ISO8601Date, null: false
    field :membership, Int, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :slug, String, null: false
    field :urls, [ UrlType ], null: false
  end
end
```
now you can query for Urls through their project:


![query a 1:n relationship with graphql](images/graphql-query-relationship.png)


#### inverse relationship


what would you need to do, to make a query
from Url to Project possible?

```
{
  url(id:2077){
    id
    url
    urlType
    title
    project {
      title
    }
  }
}
```

#### implementation of the inverse relationship

Answer: add a field project to UrlType:

```
module Types
  class UrlType < Types::BaseObject
    field :id, GraphQL::Types::ID, null: false
    field :title, String, null: true
    field :url, String, null: true
    field :url_type, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :project, ProjectType, null: false
  end
end
```

![query a 1:n relationship with graphql (reverse)](images/graphql-query-belongs-to.png)


### More Types

In Ruby and JavaScript we often use Strings to store all
kinds of values.   In the example
above, `Url.url_type` only has three possible values: 'Link','Repository','Award'.

GraphQL comes with an Enum Type that we can use for that

#### define the Enum Type:

```
rails g graphql:enum UrlTypeEnum Link Repository Award
      create  app/graphql/types/url_type_enum_type.rb
```

```
module Types
  class UrlTypeEnumType < Types::BaseEnum
    value "Link"
    value "Repository"
    value "Award"
  end
end
```

#### using the Enum Type


This can now be used in `UrlType`:

```
module Types
  class UrlType < Types::BaseObject
    field :id, GraphQL::Types::ID, null: false
    field :title, String, null: true
    field :url, String, null: true
    field :url_type, UrlTypeEnumType, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :project, ProjectType, null: false
  end
end
```

#### Types: uses and limitations


The data returned by a query is still JSON, and cannot contain
enums, only Strings.

![querying an enum gives a string](images/graphql-enum.png)


In the documentation you can see that
only three Strings are valid.  The GraphQL API will
validate this both in Queries and in Mutations.


## A lot more to learn

This guide has not touched on:

* mutations
* filtering, searching
* pagination
* resolving graphql queries that are not directly mapped to models
* ...



### See Also

- [GraphQL Guides: Ruby ](https://www.howtographql.com/graphql-ruby/0-introduction/)
- [Pragmatic Tutorial: GraphQL?](https://pragmaticstudio.com/tutorials/what-is-graphql) (see also part 2 + 3)
- [Apollo Client + Server](https://www.apollographql.com/) in JavaScript
- [API Platform](https://api-platform.com/) to build REST + GraphQL APIs in PHP
- [Analyzing the Twitch.tv GraphQL API](https://wundergraph.com/blog/graphql_in_production_analyzing_public_graphql_apis_1_twitch_tv)
