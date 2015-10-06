# Rails Lite
[Amazon Web Services link][heroku]

[heroku]: https://corgiserver.site

# Overview
This is a web application backed by a database inspired by Rails. The server provides RESTful HTTP routes which allow visitors to create cats, view cats, or browse an index of cats. Additionally, some of the basic Rails functionality such as flash and params have been implemented.

The live version is currently hosted hosted by Amazon Web Services on an EC2 micro instance. The database for the server is SQLite3, with a custom object-relational mapper (ORM) similar to ActiveRecord.

# Server
The server uses Ruby's built in WEBrick server toolkit to respond to HTTP requests. Currently pages are served in single, mostly-static HTMLpages.

In order to start the server, only the following code is needed using Ruby's built in WEBrick toolkit:

```ruby
require 'webrick'

server = WEBrick::HTTPServer.new(Port: 80)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
```

The assignment of `server` creates a WEBrick server object capable of listening to a port (given here as the argument) for HTTP requests (`req`), interpreting those requests using a router (see the `route` assignment above) to formulate a response, and finally sending a response (`res`) in the form of a single HTML document.

The `HTTPServer#mount_proc` method takes a root path as an argument, and a block, which is passed `req` and `res` as block variables. A router object, previously initialized in the `server.rb code`, is passed the request and an empty response object. The router determines the appropriate controller given the request, and receives the populated response, which WEBrick passes back to the requester, completing the request-response cycle for this server.

This WEBrick server is run by Ruby on an EC2 micro instance hosted on Amazon Web Services (AWS).

The code above is found in `bin/server.rb` which contains the initialization code for the server.

# Router
The purpose of the router is to interpret an incoming HTTP request, and instantiate the correct controller to populate the outgoing response. In `server.rb`, the router is initialized using the following code:

```ruby
router = Router.new
router.draw do
  get  Regexp.new("^/$"), CorgisController, :index
  ...
end
```

In the above code, a new router object is created, and then `Router#draw` is called which takes a block, and evaluates it in the context of the router object (`self` is set to the router), allowing Rails-like readability for assigning the routes.

Each route is assigned using a method named by the appropriate HTTP verb for the route (`get` in the above block of code). The method takes three inputs: a regular expression to match the route (`Regexp.new`), the controller to instantiate ('CorgisController'), and the controller action to populate the response (`:index`).

The code for the router can be found in `lib/aux/router.rb`

# Controllers
A controller object is created by the router in order to populate an empty HTTP response to send back to a requester. This occurs in `router.rb:24`

```ruby
  controller_class.new(req, res, route_params).invoke_action(action_name)
```

Here a new object (of the `controller_class` class) is initialized and passed the request and response objects as well as a deeply nested hash of route parameters (`route_params`). The newly created controller then runs the action for the route (`action_name`).

The `server.rb` file initializes many of the controller actions for CorgiServer (the CorgisController and HumansController) typical of a database-backed web-application (CRUD actions). The controllers initialized in `server.rb` inherit from `ControllerBase`, a class defined in `lib/aux/controller_base.rb`.

The `ControllerBase` class mainly takes care of rendering content in response to a request (see `ControllerBase#render_content`) or redirecting to the appropriate resource (see 'ControllerBase#redirect_to').

The `ControllerBase` class also provides controllers with access to many helpful, Rails-like objects such as `params`, `session`, and `flash` which are implemented here. The source code for these objects can be found in the `lib/aux` folder.

## `ControllerBase#render_content`
The `render_content` method is used to set the values of attributes in a `WEBrick::HTTPResponse` object. The method is shown below:

```ruby
def render_content(content, content_type)
  raise "Already rendered" if already_built_response?
  res.content_type = content_type
  res.body = content
  @already_built_response = true
  session.store_session(res)
end
```

The `render_content` method takes in `content`, which is a string created from an evaluated ERB template. The `content_type` input sets the response type, in this case 'text/html'. An error is raised in the case of a double render. Otherwise, the response body, and content_type attributes are set, and the controller stores the session variables in a session cookie in order to keep track of user data and other variables.

## `ControllerBase#redirect_to`
The `redirect_to` method is used similarly to set response attributes similar to the `render_content` method. The method is shown below:

```ruby
def redirect_to(url)
  raise "Already rendered" if already_built_response?
  res.status = 302
  res.header['location'] = url
  @already_built_response = true
  session[:flash] = flash.store
  session[:authenticity_token] = SecureRandom.urlsafe_base64(16)
  session.store_session(res)
end
```

There are once again checks to see if the controller has already rendered. The status of the response is set to 302 to indicate a redirect response, with the location key in the response header is set to the url set by the method input. Once again, session variables are stored at the end of the method.

# DB
The CorgiServer uses a SQLite3 database to store a simple db schema and rows.

The schema for the database is shown below:

## corgis
column name | data type | details
------------|-----------|-----------------------
id          | integer   | not null, primary key
owner_id    | integer   | not null, foreign key (references humans)
name        | string    | not null
description | string    | not null

## humans
column name | data type | details
------------|-----------|-----------------------
id           | integer   | not null, primary key
fname        | string    | not null
lname        | string    | not null
session_token| string    | not null

The humans (users) on the site have a `has_many` relationship with Corgis. The humans are identified only by first and last name, and their sessions are distinguished using the session_token attribute.

The rows in the database are made available to the Ruby controllers using ActiveRecordLite, a custom ORM meant to provide many of the functions of ActiveRecord in Rails. ActiveRecordLite can be found in the lib/activerecord folder.
