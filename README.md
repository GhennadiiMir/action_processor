## ActionProcessor

Simple framework for implementation application business logic as a set of "ActionProcessors" - separate classes dedicated to specific "business events" usually mapped to real-world events, each of them affecting application state in multiple ways. 

Let's imagine online store, where we can process sevelal events, raleted to order:
* `Orders::Create`
    * we create `Order` record and several related `OrderLine` - one per each unique product
    * we check phisical availablity and reservations for each product and store localtion and decide what to do if something wrong
    * we make reservations for limited time to avoid over-selling when two different customers paid for same item
    * request delivery quotation
* `Orders::Paid` - we process payment confirmation
    * make temporary reservation of goods permanent
    * mark `Order` state as `ready_to_ship`
    * enqueue `PackingRequest` for warehouse
    * change custoer's balance
* `Orders::Retire`
    * relese temporary reservation of goods
    * mark order as `abandoned`
* `Orders::Ship`
    * save package dimensions and weight
    * place delivery order to currier service
    * remove goods reservations and adjust stock quantity
    * change order's status
    * send shipping confirmation message to customer
* `Orders::Cancel`
    * etc.


There some obvious advantage for grouping all code for each step in separate class:
* easy to map real-world events into ActiveProcessors and descibe clear specifications and unit tests for them
* we can call same "Processor" from several places - from "classic" controller, API controller, graphQL controller, from ActiveJob, etc.
* all relaeted code placed in separate file, where main steps listed in eloquent manner in the main `run` method (see details below)
* IMHO it's the only elegant solution for "fat controllers" and "fat models". Especially when we remember that such complex operation usually is not related to one specifc model or controller

## Installation

```ruby
  gem 'action_processor'
```


## Quick start

We use `ActionProcessor` by calling class method `run` like this:

```ruby
@resilt = Payments::SendMoney.run params.permit(:payer_id, :payee_id, :amount)
@resilt.success? # => true
```

Example implementation:
```ruby
class Payments::SendMoney < ActionProcessor::Base

  # exposed variables
  attr_reader :payer, :payee, :payment

  # for internal use
  attr_reader :amount

  # guidance about "run" method you can find below
  def run
    required_params :payee_id, :payer_id, :amount
    allowed_params :payment_description
    
    step :normalise_and_validate_amount
    User.transaction do
      step :find_payer
      step :find_payee
      step :validate_payee
      step :update_balances_and_create_payment
    end
  end

  private 

  def normalise_and_validate_amount
    @amount = params[:amount].to_f.round(2)
    return if amount > 0.0

    fail! "Amount should be higher than zero", :amount
  end

  def find_payer
    @payer = User.find_by(id: params[:payer_id])
    return if @payer.present?

    fail! "Payer not found", :payer_id
  end

  def find_payee
    @payee = User.find_by(id: params[:payee_id])
    return if @payee.present?

    fail! "Payee not found", :payee_id
  end

  def validate_payee
    return if @payee.id != @payer_id

    fail! "You can't send money to yourself", :payee_id
  end

  def update_balances_and_create_payment
    payer_balance = payer.balance - amount
    payee_balance = payee.balance + amount

    if payer_balance < 0.0
      fail! "You have have no enough funds", :amount
      return
    end

    @payer.update balance: payer_balance
    @payee.update balance: payee_balance

    @payment = Payment.new(payer: @payer, payee: @payee, amount: amount, status: "completed",
                           payer_balance: payer_balance, payee_balance: payee_balance, moment: Time.now)

    fail!(@payment) unless @payment.save
  end
end
```

## ActionProcessor::Base

### Optimal usege of attr_reader

Usually we expose two types of significant instance variables

1. for safer internal use like: `new_balance = payer.balance - amount` instead of `new_balance = @payer.balance - @amount`
2. for usage outside the class: `redirect_to payment_url(@resilt.payment)`

So we advise to split list of variables into to portions, the people who review/debug the code can understand 
which variables meant to be used outside the class at a glance.

### `run` method

This is main method describing entire processing logic step-by-step

Inside it we usually place:

1) optional lists of required and|or allowed params:

```ruby
  def run
    required_params :payer_id, :payee_id, :amount
    allowed_params :payment_description
    ...
  end
```  
Errors will be logged:
* if some of params named in `required_params` are missing
* if `allowed_params` specified and will be passed any named param not included in `required_params` and `allowed_params` lists

2) list of all steps

The list of steps usually a good overview of what processo should do. Consequent `step` executed only if all previous steps did not produce any errors.

If you need to execute a step even if any previous step failed, use `step_always`. This could be useful, for example:
* to prepare redirect_url depending on errors presence 
* to produce custom error messages
* when we need to perform all reasonable validations even if previous failed, so user will get relevant information to edit all wrong fields

Steps could be wraped inside transaction. In this case any `fail!` method inside wrapped steps will not only add an error but also raile `ActiveRecord::Rollback` error.

We can pass additional named params to the `step` and `step_always`:

```ruby
  def run
    # ...
    step :find_invoice
    step :validate_customer
    step :validate_lines
    # ...
  end
  # ...
  def find_invoice
    @invoice = Invoice.find_by(id: params[:invoice_id])
    return if @invoice.present?

    fail! "Invoice not found", :invoice_id
  end 

  def validate_lines
    @invoice.lines.each |line|
      step_always :validate_line, line: line
    end
  end
  # ...
```
__Note 1__: we can't just put 

```ruby
    @invoice.lines.each |line|
      step_always :validate_line, line: line
    end
```

instead of `step :validate_lines` since if the `@invoice` will no be found expression `@invoice.lines` will raise an error.

__Note 2__: We use `step_always` inside the loop through lines since we want to validate all lines and send error messages for all invalid lines to the user.

Inside this instance method we usually list all eloquently named steps
  # step's code will not be executed if any previous step raise any errors
  # you can use step_always to define a step which will be executed
  # even if there are errors, like:
  #   step_always :define_redirect_url -->

### `fail!` method

First parameter could be:
* String - error message
* array of String - several error messages
* object derived from ActiveRecord::Model class - Processor will extract errors from it

Second parameter is optional, it specifies the input field id to whicj provided message(s) belong. This is useful for placing every message aside of relevant field in the form.

Example of usage:
* `fail! "Your account is blocked"`
* `fail! "Payee should be selected", :payee_id`
* `fail! ["Amount should be positive", "Payee should be selected"]`
* `fail! ["Password should contain digits", "Password should be at least 6 symbols long"], :password`
* `fail! @order unless @order.save`

### `success?` and `errors?` methods

Helpers which useful to check if any errors logged.

### `json_outcome` method

Useful helper for usage in API controllers, for example:

```ruby
  def create
    @resilt = Payments::SendMoney.run payment_params
    render json: @resilt.json_outcome
  end
```
It returns data by calling `successful_json` or `failed_json` depending on errors' presence.

Method `successful_json` usually should be overwritten in your Processo class, since defined version just provide `{ success: true }` which is not informative enough.

## ActionProcessor::Errors

Usually we extract errors occurred when Processor for three reasons:

### Inspect errors for debug purposes

```ruby
@resilt = Payments::SendMoney.run payment_params
puts @resilt.errors.all
# => [{:messages=>["You have have no enough funds"], :step=>:update_balances_and_create_payment, :attribute=>:amount}]
```

We will get a `Hash` with all data about errors: messages, attributes which those messages related to and even step which raised every error. If error was raisen outside of any step, we'll see `step: :not_specified`.

### Show error messages to the user

```ruby
@resilt = Payments::SendMoney.run payment_params

@resilt.errors.full_messages # => ["Your account is blocked, you unable to send money", ["Payee should be selected"]]
puts @resilt.errors.full_messages.join("; ") # => we'll have one string with semicolon-separated messages
```

### Errors grouped by input field to display in the form

```ruby
@resilt = Payments::SendMoney.run payment_params

# get messages to show aside "Payee" field in the form
@resilt.errors.for_attribute(:payee_id) # => ["Payee should be selected"]

# get general messages which not related to any field
@resilt.errors.for_attribute(:not_specified) # => ["Your account is blocked, you unable to send money"]

# get all messages for sennding to javascript frontend
render json: @resilt.errors.grouped_by_attribute
# => { not_specified: ["Your account is blocked, you unable to send money"], payee_id: ["Payee should be selected"]}
```

