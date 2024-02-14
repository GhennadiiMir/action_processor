require "action_processor"

class TestableProcessor < ActionProcessor::Base
  attr_reader :logger

  def initialize(params)
    super
    @logger = []
  end

  private

  def step_1
    report :performed_step_1
  end

  def step_2
    report :performed_step_2
  end

  def step_3
    report :performed_step_3
  end

  def report(message)
    @logger << message
  end
end
