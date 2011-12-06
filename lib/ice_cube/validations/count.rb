module IceCube

  module Validations::Count

    def count(max)
      replace_validations_for(:count, [Validation.new(max, self)]) # replace
      self
    end

    class Validation

      attr_reader :rule, :max

      def initialize(max, rule)
        @max = max
        @rule = rule
      end

      def validate(time, schedule)
        if rule.uses && rule.uses >= max
          raise CountExceeded
        end
      end

    end

  end

end
