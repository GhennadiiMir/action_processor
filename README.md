## ActionProcessor

Micro framework to implement "business transactions" in your complex Rails application. Conventions, examples and reasoning 
behind this approach could be found in [wiki](https://github.com/GhennadiiMir/action_processor/wiki).

The idea of this gem was formed over the years when authors worked on multiple complex real-world Rails applications. 
We believe that `ActionProcessor` helping to reach same goals as well-known [service objects](https://www.toptal.com/ruby-on-rails/rails-service-objects-tutorial) while providing much more usable, consistent and elegant way.

## Quick start

```ruby
  gem 'action_processor'
```

We recommend place all processor implementations for each business transaction in `Rails.root.join("app/processors")` folder.

Please read the [Wiki](https://github.com/GhennadiiMir/action_processor/wiki) to understand the logic of `ActionProcessor` usage.


