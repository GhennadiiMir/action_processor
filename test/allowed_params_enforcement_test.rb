require "minitest/autorun"
Dir[File.dirname(__FILE__) + "/processors/params/*.rb"].each { |file| require file }

class AllowedParamsEnforcementTest < Minitest::Test
  def test_that_allowed_params_enforced
    # no parameters provided is OK when allowed_params specified
    result = Processors::Params::WithAllowedOnly.run

    puts result.errors.all
    assert result.success?
    assert_equal [:performed_step_1, :performed_step_2, :performed_step_3], result.logger

    # all allowed_params are accepted
    result = Processors::Params::WithAllowedOnly.run allowed_param_1: "value1", allowed_param_2: "value2"

    assert result.success?
    assert_equal [:performed_step_1, :performed_step_2, :performed_step_3], result.logger

    # some allowed params could be missed
    result = Processors::Params::WithAllowedOnly.run allowed_param_1: "value1"

    assert result.success?
    assert_equal [:performed_step_1, :performed_step_2, :performed_step_3], result.logger
  end
end
