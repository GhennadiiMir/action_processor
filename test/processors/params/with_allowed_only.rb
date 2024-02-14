require_relative "../testable_processor"
module Processors
  module Params
    class WithAllowedOnly < TestableProcessor
      def run
        allowed_params :allowed_param_1, :allowed_param_2

        step :step_1
        step :step_2
        step :step_3
      end
    end
  end
end
