require_relative "../testable_processor"
module Processors
  module Params
    class WithRequiredOnly < TestableProcessor
      def run
        required_params :required_param_1, :required_param_2

        step :step_1
        step :step_2
        step :step_3
      end
    end
  end
end
