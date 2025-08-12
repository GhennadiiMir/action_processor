# ActionProcessor

Micro framework to implement "business transactions" in your complex Rails application. Conventions, examples and reasoning 
behind this approach could be found in [wiki](https://github.com/GhennadiiMir/action_processor/wiki).

## Theoretical background

`action_processor` gem is a tool for organizing and executing complex business logic in a structured, step-by-step manner.

This gem addresses the [cross-cutting concern](https://en.wikipedia.org/wiki/Cross-cutting_concern) of **cohesion** and **modularity** by providing a clear, centralized place to define a sequence of actions. Instead of scattering logic for a single process (like sending money) across multiple controllers, models, and service objects, `ActionProcessor` consolidates it into a single, cohesive class.

Here's how `action_processor` relates to cross-cutting concerns:

* **Logic Orchestration:** It provides a defined framework (`run` method, `step`s) to handle the entire lifecycle of a complex process, ensuring that the logic is easy to follow and debug. This prevents the "tangling" of code where a single action's logic is spread across different parts of an application.
* **Transaction Management:** By wrapping steps in a `User.transaction` block, the gem ensures that a series of database operations either all succeed or are all rolled back, handling a crucial aspect of data integrity. This is a common cross-cutting concern that is cleanly managed by the gem's structure.
* **Error Handling:** It centralizes error handling with the `fail!` method, separating the logic of what went wrong from the core business steps. This allows for a uniform way to handle validation and failure, and the `ActionProcessor::Errors` class provides a structured way to access and present errors. This prevents error handling code from being scattered throughout the application.
* **Input Validation:** The `required_params` and `allowed_params` methods provide a simple, declarative way to validate input at the very beginning of the process. This separates the concern of parameter validation from the main business logic steps.

In summary, the gem's design promotes a [**Single Responsibility Principle**](https://en.wikipedia.org/wiki/Single-responsibility_principle) for complex operations, which is a key strategy for managing cross-cutting concerns and improving code modularity. It provides a standardized and reusable structure for processes, moving common functionalities like transaction management, validation, and error reporting out of individual steps and into the overarching framework.

## Quick start

```ruby
  gem 'action_processor'
```

We recommend place all processor implementations for each business transaction in `Rails.root.join("app/processors")` folder.

Please read the [Wiki](https://github.com/GhennadiiMir/action_processor/wiki) to understand the logic of `ActionProcessor` usage.


