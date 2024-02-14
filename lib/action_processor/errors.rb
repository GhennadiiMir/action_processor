# frozen_string_literal: true

require "active_support/core_ext/hash/indifferent_access"

module ActionProcessor
  class Errors
    attr_reader :all

    def initialize
      @all = []
    end

    def add(messages, step = :not_specified, attribute = :not_specified)
      step ||= :not_specified # in case we will receive explicit nil as step parameter
      @all << {messages: [messages].flatten, step: step.to_sym, attribute: attribute.to_sym}
    end

    def concat(more_errors)
      raise ArgumentError, "Expected an ActionProcessor::Errors object" unless more_errors.is_a?(ActionProcessor::Errors)
      @all += more_errors.all
    end

    # returns array of strings with user friendly error messages
    def messages
      all_messages = []
      @all.each do |e|
        all_messages += e[:messages]
      end
      all_messages
    end

    alias_method :full_messages, :messages  # for compatibility with ActiveRecord::Errors

    def for_attribute(attr)
      @grouped_by_attribute[attr]
    end

    def grouped_by_attribute
      return @grouped_by_attribute if @grouped_by_attribute.present?

      # we assume that all errors will be present
      # at the time when this method called first time
      @grouped_by_attribute = {}.with_indifferent_access
      @all.each do |err|
        @grouped_by_attribute[err.attribute] ||= []
        @grouped_by_attribute[err.attribute] += err[:messages]
      end
      @grouped_by_attribute
    end
  end
end
