require "minitest/autorun"
require_relative "processors/for_testing_fail_method"

class FailMethodTestTest < Minitest::Test
  def test_all_steps_processed_if_no_failures
    result = Processors::ForTestingFailMethod.run

    assert result.success?
    expected_logs = [:performed_step_1, :processed_step_failure_with_string,
      :processed_step_failure_with_array, :processed_step_failure_with_action_processor_errors,
      :processed_step_failure_with_active_record_errors, :performed_step_3,
      :processed_step_which_should_be_performed_always]
    assert_equal expected_logs, result.logger
  end

  def test_that_string_parameter_accepted
    result = Processors::ForTestingFailMethod.run string_error: "Some error message"

    assert result.errors?
    expected_logs = [:performed_step_1, :processed_step_failure_with_string, :processed_step_which_should_be_performed_always]
    # After first failure only "step_always" will be performed
    assert_equal expected_logs, result.logger

    expected_errors = [{messages: ["Some error message"], step: :failure_with_string, attribute: :not_specified}]
    assert_equal expected_errors, result.errors.all
    expected_error_messages = ["Some error message"]
    assert_equal expected_error_messages, result.errors.messages
    assert_equal expected_error_messages, result.errors.full_messages
  end

  def test_that_array_parameter_accepted
    result = Processors::ForTestingFailMethod.run array_error: ["Some error message", "Another error message"]

    assert result.errors?
    expected_logs = [:performed_step_1, :processed_step_failure_with_string, :processed_step_failure_with_array, :processed_step_which_should_be_performed_always]
    assert_equal expected_logs, result.logger

    expected_errors = [{messages: ["Some error message", "Another error message"], step: :failure_with_array, attribute: :not_specified}]
    assert_equal expected_errors, result.errors.all
    expected_error_messages = ["Some error message", "Another error message"]
    assert_equal expected_error_messages, result.errors.messages
    assert_equal expected_error_messages, result.errors.full_messages
  end

  def test_that_action_processor_errors_accepted
    previous_result = Processors::ForTestingFailMethod.run string_error: "Some error message"
    result = Processors::ForTestingFailMethod.run action_processor_errors: previous_result.errors

    assert result.errors?
    expected_logs = [:performed_step_1, :processed_step_failure_with_string, :processed_step_failure_with_array,
      :processed_step_failure_with_action_processor_errors, :processed_step_which_should_be_performed_always]
    assert_equal expected_logs, result.logger
    expected_errors = [{messages: ["Some error message"], step: :failure_with_string, attribute: :not_specified}]
    assert_equal expected_errors, result.errors.all
  end
end
