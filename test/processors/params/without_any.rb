require_relative "../testable_processor"
module Processors
  module Params
    class WithoutAny < TestableProcessor
      def run
        step :step_1
        step :step_2
        step :step_3
      end
    end
  end
end
