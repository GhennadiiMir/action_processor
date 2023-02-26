## ActionProcessor

Micro framework to implement service objects in a more logical and consistent way.

The idea of this gem was formed over the years when authors worked on multiple complex real-world Rails applications. The [service objects](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial) is in a nutshell of it.  

Some conventions, examples and reasoning behind could be found in [wiki](https://github.com/GhennadiiMir/action_processor/wiki).


## Work in progress!

Since currently the gem published as a draft it comes with very restrictive dependencies (Rails 7). But the code itself is very compact, just two files (we recommend to review them to understand the logic better):
* base class [ActionProcessor::Base](https://github.com/GhennadiiMir/action_processor/blob/master/lib/action_processor/base.rb) 
* helper class [ActionProcessor::Errors](https://github.com/GhennadiiMir/action_processor/blob/master/lib/action_processor/errors.rb)

So you can easily copy-paste them right into you existing application and make it work in virtully any environment. We usually place them in `Rails.root("app/processors/action_processor")` folder, while all processors tree kept inside `Rails.root("/app/processors")` root.


## Installation

```ruby
  gem 'action_processor'
```

## Quick start

[Wiki, work in progress](https://github.com/GhennadiiMir/action_processor/wiki)