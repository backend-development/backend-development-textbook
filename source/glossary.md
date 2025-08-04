Glossary
==========================

This glossary defines key technical terms used throughout this textbook. Terms are listed alphabetically with links to the relevant chapters where they are explained in detail.

-------------------------------------------------------------------------------


# Glossary



## A

**ActiveRecord**: A Rails implementation of the Active Record pattern that provides an object-relational mapping (ORM) layer. It allows you to interact with database tables as if they were Ruby objects. See [Rails: Models and ActiveRecord](rails_database_and_model.html).

**API (Application Programming Interface)**: A set of rules and protocols that allows different software applications to communicate with each other. APIs define how to request data from a service and what data format to expect in response. See [REST APIs](rest-api.html) and [GraphQL APIs](graphql-api.html).

**Authentication**: The process of verifying who a user is. This typically involves checking credentials like username and password. See [Rails Authentication](rails_authentication.html) and [Security](security.html).

**Authorization**: The process of determining what actions a user is allowed to perform after they have been authenticated. See [Security](security.html).

## B

**Backend**: The server-side part of a web application that handles data processing, business logic, and database operations. The backend is not visible to users but powers the frontend.

**Backend Development**: The practice of creating server-side applications that handle data, business logic, and provide services to frontend applications.

**BCrypt**: A password hashing function used for securely storing passwords. Rails uses BCrypt through the `has_secure_password` method. See [Rails Authentication](rails_authentication.html).

**Browser Cache**: A storage mechanism in web browsers that stores copies of web resources to improve loading speed. See [Caching](caching.html).

## C

**Cache**: A temporary storage area that holds frequently accessed data to improve performance. Caching reduces the need to fetch data from slower sources like databases. See [Caching](caching.html).

**Cache Eviction**: The process of removing items from a cache when storage is full or items expire. See [Caching](caching.html).

**Cache Store**: The storage mechanism used for caching data in Rails applications (e.g., memory, file, Redis, Memcached). See [Caching](caching.html).

**Client**: A computer or application that requests services from a server. In web development, the client is typically a web browser.

**Cookie**: A small piece of data sent from a web server to a browser that is stored and sent back with subsequent requests. Used for maintaining state and sessions. See [Rails Authentication](rails_authentication.html).

**CRUD**: An acronym for Create, Read, Update, Delete - the four basic operations that can be performed on data in a database. See [Rails: Models and ActiveRecord](rails_database_and_model.html).

**CSRF (Cross-Site Request Forgery)**: A security vulnerability where malicious websites can perform actions on behalf of authenticated users. See [Security](security.html).

## D

**Database**: An organized collection of data stored electronically. Databases allow for efficient storage, retrieval, and management of information.

**Deployment**: The process of making a software application available for use, typically by uploading it to a server or cloud platform. See [Deploying Rails](deploying_rails.html) and [Deploy to PaaS](deploy-to-paas.html).

**Devise**: A popular Rails gem for handling authentication with features like user registration, password reset, and email confirmation. See [Rails Authentication](rails_authentication.html).

## E

**Event Loop**: A programming construct that waits for and dispatches events or messages in a program. Node.js uses an event loop for handling asynchronous operations. See [Node.js Basics](node_basics.html).

## F

**Fragment Caching**: A Rails feature that allows caching specific parts of a view or partial. See [Caching](caching.html).

**Framework**: A pre-built structure that provides common functionality for developing applications. Frameworks help developers avoid writing code from scratch for common tasks.

**Frontend**: The client-side part of a web application that users interact with directly. This includes the user interface and user experience components.

## G

**GraphQL**: A query language and runtime for APIs that allows clients to request exactly the data they need. See [GraphQL APIs](graphql-api.html).

**GraphQL Playground**: A web-based IDE for exploring GraphQL APIs with features like introspection and autocompletion. See [GraphQL APIs](graphql-api.html).

## H

**HATEOAS (Hypermedia as the Engine of Application State)**: A REST constraint that requires APIs to provide hypermedia links to guide clients through the application state. See [REST APIs](rest-api.html).

**HTTP (Hypertext Transfer Protocol)**: The protocol used for transmitting data over the web. HTTP defines how messages are formatted and transmitted between web browsers and servers.

**HTTPS**: A secure version of HTTP that encrypts data transmitted between the client and server.

**HTTP Methods**: Standard operations in HTTP including GET, POST, PUT, DELETE, PATCH, etc. See [REST APIs](rest-api.html).

## I

**Injection Attack**: A security vulnerability where malicious code is inserted into a program through user input. Common types include SQL injection and XSS. See [Security](security.html).

**Integration Test**: A test that exercises multiple components of an application working together. See [Testing](testing.html).

**Introspection**: A GraphQL feature that allows clients to query the API about its schema and available operations. See [GraphQL APIs](graphql-api.html).

## J

**JWT (JSON Web Token)**: A compact, URL-safe means of representing claims to be transferred between two parties. Used for authentication and authorization. See [Advanced Authentication](adv_authentication.html).

## L

**libuv**: A cross-platform asynchronous I/O library used by Node.js for handling file system operations, networking, and other asynchronous tasks. See [Node.js Basics](node_basics.html).

**Load Balancer**: A device that distributes network traffic across multiple servers to improve performance and reliability. See [Caching](caching.html).

## M

**Middleware**: Software that acts as a bridge between different applications or components. Middleware processes requests and responses between the client and server.

**Model**: In Rails, a class that represents a database table and contains the business logic for data manipulation. See [Rails: Models and ActiveRecord](rails_database_and_model.html).

**MVC (Model-View-Controller)**: A software architecture pattern that separates an application into three main components: Model (data and business logic), View (user interface), and Controller (handles user input and coordinates between Model and View).

**Mutation**: In GraphQL, an operation that modifies data on the server. See [GraphQL APIs](graphql-api.html).

## N

**Node.js**: A JavaScript runtime built on Chrome's V8 engine that allows running JavaScript on the server side. See [Node.js Basics](node_basics.html).

**npm (Node Package Manager)**: The default package manager for Node.js that allows installing and managing JavaScript libraries. See [Node.js Basics](node_basics.html).

**NVM (Node Version Manager)**: A tool for managing multiple Node.js versions on a single system. See [Node.js Basics](node_basics.html).

## O

**ORM (Object-Relational Mapping)**: A programming technique for converting data between incompatible type systems in object-oriented programming languages. See [Rails: Models and ActiveRecord](rails_database_and_model.html).

**OWASP**: The Open Web Application Security Project, a nonprofit foundation that works to improve software security. See [Security](security.html).

## P

**Package.json**: A file that contains metadata about a Node.js project, including dependencies and scripts. See [Node.js Basics](node_basics.html).

**Password Digest**: An encrypted version of a password stored in the database instead of the plain text password. See [Rails Authentication](rails_authentication.html).

**Prepared Statement**: A database feature that pre-compiles SQL statements to prevent SQL injection attacks. See [Security](security.html).

**Production**: The live environment where a software application is used by real users. Production environments are optimized for performance and reliability.

**Protocol**: A set of rules that define how data is transmitted and received between devices or applications.

## Q

**Query**: In GraphQL, an operation that retrieves data from the server. See [GraphQL APIs](graphql-api.html).

**Query Cache**: A Rails feature that caches database queries to improve performance. See [Caching](caching.html).

## R

**Rails Console**: An interactive Ruby shell with the Rails application loaded, used for testing and debugging. See [Rails: Models and ActiveRecord](rails_database_and_model.html).

**REST (Representational State Transfer)**: An architectural style for designing networked applications. REST APIs use standard HTTP methods (GET, POST, PUT, DELETE) to perform operations on resources. See [REST APIs](rest-api.html).

**Route**: A URL pattern that maps to a specific function or controller action in a web application.

**Ruby on Rails**: A web application framework written in Ruby that follows the MVC pattern and emphasizes convention over configuration.

## S

**Schema**: In GraphQL, a description of the data types and operations available in the API. See [GraphQL APIs](graphql-api.html).

**Server**: A computer or software that provides services to other computers (clients) over a network. Web servers handle HTTP requests and serve web pages.

**Session**: A way to store user-specific data on the server between requests. Sessions help maintain user state across multiple page visits. See [Rails Authentication](rails_authentication.html).

**SOAP**: A protocol for exchanging structured information in web services using XML. See [REST APIs](rest-api.html).

**SQL Injection**: A security vulnerability where malicious SQL code is inserted into database queries through user input. See [Security](security.html).

**SSL/TLS**: Security protocols that provide encryption and authentication for data transmitted over networks. HTTPS uses SSL/TLS to secure web communications.

**System Test**: A test that exercises the entire application stack, including the browser, to simulate real user interactions. See [Testing](testing.html).

## T

**Test-Driven Development (TDD)**: A software development methodology where tests are written before the actual code. See [Testing](testing.html).

**Token**: A piece of data that represents a user's authentication status. Tokens are often used in stateless authentication systems like JWT (JSON Web Tokens).

**Type**: In GraphQL, a definition of the structure and properties of data objects. See [GraphQL APIs](graphql-api.html).

## U

**Unit Test**: A test that focuses on testing individual components or functions in isolation. See [Testing](testing.html).

## V

**V8**: Google's JavaScript engine that powers Node.js and Chrome browser. See [Node.js Basics](node_basics.html).

**Validation**: The process of checking that data meets certain criteria before processing it. Validation helps ensure data quality and security. See [Rails: Models and ActiveRecord](rails_database_and_model.html).

**Version Control**: A system that tracks changes to source code over time, allowing developers to collaborate and maintain a history of modifications.

**View**: In Rails MVC, the component responsible for rendering the user interface and displaying data to users. See [Rails: View and Controller](rails_view_and_controller.html).

## W

**WebSocket**: A communication protocol that provides full-duplex communication channels over a single HTTP connection. See [Rails WebSockets](rails_websockets.html) and [Node WebSockets](node_websockets.html).


## X

**XSS (Cross-Site Scripting)**: A security vulnerability where malicious scripts are injected into web pages viewed by other users. See [Security](security.html).

