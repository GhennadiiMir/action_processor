# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"
require "active_record"
require_relative "errors"

module ActionProcessor
  class Base
    attr_reader :params, :errors

    def self.run(params = {})
      inst = new(params)
      inst.run
      inst
    end

    def initialize(params = {})
      @params = if params.instance_of? Hash
        params.with_indifferent_access
      else
        params
      end
      @errors = ActionProcessor::Errors.new
      @steps_stack = []
      @transaction_level = ActiveRecord::Base.connection.open_transactions
    rescue ActiveRecord::ConnectionNotEstablished
      @transaction_level = nil
    end

    def run
      raise 'Error: method "run" should be overridden to implement business logic!'
    end

    def errors?
      @errors.all.any?
    end

    def success?
      @errors.all.empty?
    end

    def json_outcome
      errors? ? failed_json : successful_json
    end

    # in most cases should be overriden to provide relevant data
    def successful_json
      {success: true}
    end

    # could be overriden to provide some specifics/advices/etc.
    def failed_json
      {success: false, errors: errors.grouped_by_attribute}
    end

    def step(step_method, **options)
      return if errors? # skip it if there are errors

      step_always(step_method, **options)
    end

    def step_always(step_method, **options)
      @steps_stack << (@current_step || :not_specified)
      @current_step = step_method
      # performs even if there are errors
      # useful for:
      #  - validation steps to return list of all errors
      #  - errors reporting and making decisions at the end of processing
      send step_method, **options
      @current_step = @steps_stack.pop
    end

    # As an "errs" params we could pass several types:
    # - String with error description
    # - array of Strings (error messages)
    # - ActiveRecord model (invalid) - its errors will be copied
    def fail!(errs, attr = :not_specified)
      if errs.class.ancestors.map(&:to_s).include?("ActiveRecord::Base")
        fail_active_record!(errs)
      elsif errs.instance_of? ActionProcessor::Errors
        @errors.concat errs
      else
        @errors.add(errs, @current_step, attr)
      end

      raise ActiveRecord::Rollback if in_transaction?
    end

    private

    # simple params presence validation
    # will initiate errors for each absent params
    def required_params(*list)
      list.flatten!
      @list_of_allowed_params ||= []
      @list_of_allowed_params += list.map(&:to_s)
      list.map(&:to_s).each do |param|
        next unless params[param].nil?

        fail! "Parameter :#{param} should be present", param
      end
    end

    # allowed params (in addition to required_params)
    # if allowed_params present method called, all params
    # provided to Processor which are not included in
    # lists specified for required_params and allowed_params
    # will cause validation error
    def allowed_params(*list)
      list.flatten!
      @list_of_allowed_params ||= []
      @list_of_allowed_params += list.map(&:to_s)

      params.each do |key, value|
        next if @list_of_allowed_params.index(key.to_s).present?

        fail! "Parameter :#{key} is not allowed", key.to_sym
      end
    end

    def fail_active_record!(record)
      record.errors.each do |err|
        fail! "#{err.attribute.to_s.humanize} #{err.message}", err.attribute
      end
    end

    def in_transaction?
      return false if @transaction_level.nil?

      ActiveRecord::Base.connection.open_transactions > @transaction_level
    end
  end
end
