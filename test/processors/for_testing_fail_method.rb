require_relative "testable_processor"
module Processors
  class ForTestingFailMethod < TestableProcessor
    def run
      allowed_params :string_error, :array_error, :action_processor_errors, :active_record_errors

      step :step_1
      step :failure_with_string
      step :failure_with_array
      step :failure_with_action_processor_errors
      step :failure_with_active_record_errors
      step :step_3
      step_always :step_which_should_be_performed_always
    end

    private

    def failure_with_string
      report :processed_step_failure_with_string
      return if params[:string_error].nil?

      fail! params[:string_error]
    end

    def failure_with_array
      report :processed_step_failure_with_array
      return if params[:array_error].nil?

      fail! params[:array_error]
    end

    def failure_with_action_processor_errors
      report :processed_step_failure_with_action_processor_errors
      return if params[:action_processor_errors].nil?

      fail! params[:action_processor_errors]
    end

    def failure_with_active_record_errors
      report :processed_step_failure_with_active_record_errors
      return if params[:active_record_errors].nil?

      fail! params[:active_record_errors]
    end

    def step_which_should_be_performed_always
      report :processed_step_which_should_be_performed_always
    end
  end
end
