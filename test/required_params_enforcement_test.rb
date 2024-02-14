require "minitest/autorun"
Dir[File.dirname(__FILE__) + "/processors/params/*.rb"].each { |file| require file }

class RequiredParamsEnforcementTest < Minitest::Test
  def test_that_required_params_enforced
    # no parameters provided is OK when no required_params specified
    result = Processors::Params::WithRequiredOnly.run

    assert result.errors?
    assert_equal [], result.logger
    expected_error_messages = ["Parameter :required_param_1 should be present", "Parameter :required_param_2 should be present"]
    assert_equal expected_error_messages, result.errors.messages

    # provide only one required param
    result = Processors::Params::WithRequiredOnly.run required_param_1: "value1"

    assert result.errors?
    assert_equal [], result.logger
    expected_error_messages = ["Parameter :required_param_2 should be present"]
    assert_equal expected_error_messages, result.errors.messages

    # additionl random parameter changes nothing
    result = Processors::Params::WithRequiredOnly.run required_param_1: "value1", random_param: "value2"

    assert result.errors?
    assert_equal [], result.logger
    expected_error_messages = ["Parameter :required_param_2 should be present"]
    assert_equal expected_error_messages, result.errors.messages

    # provide both required params
    result = Processors::Params::WithRequiredOnly.run required_param_1: "value1", required_param_2: "value2"

    assert result.success?
  end

  def test_that_allowed_params_will_not_change_enforcement_of_required
    result = Processors::Params::WithAllowedAndRequired.run

    assert result.errors?
    assert_equal [], result.logger
    expected_error_messages = ["Parameter :required_param_1 should be present", "Parameter :required_param_2 should be present"]
    assert_equal expected_error_messages, result.errors.messages

    # provide only one required param
    result = Processors::Params::WithAllowedAndRequired.run required_param_1: "value1"

    assert result.errors?
    assert_equal [], result.logger
    expected_error_messages = ["Parameter :required_param_2 should be present"]
    assert_equal expected_error_messages, result.errors.messages

    # provide both required params
    result = Processors::Params::WithAllowedAndRequired.run required_param_1: "value1", required_param_2: "value2"
    assert result.success?
    assert_equal [:performed_step_1, :performed_step_2, :performed_step_3], result.logger
  end

  def test_that_adding_allowed_params_stops_acceptance_of_random_parameters
    result = Processors::Params::WithAllowedAndRequired.run required_param_1: "value1", random_param: "value2"

    assert result.errors?
    assert_equal [], result.logger
    expected_error_messages = ["Parameter :required_param_2 should be present", "Parameter :random_param is not allowed"]
    assert_equal expected_error_messages, result.errors.messages
  end
end
