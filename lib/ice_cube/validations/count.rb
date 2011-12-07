module IceCube

  module Validations::Count

    def count(max)
      replace_validations_for(:count, [Validation.new(max, self)]) # replace
      self
    end

    class Validation

      attr_reader :rule, :count

      def initialize(count, rule)
        @count = count
        @rule = rule
      end

      def validate(time, schedule)
        if rule.uses && rule.uses >= count
          raise CountExceeded
        end
      end

      def build_ical(builder)
        builder['COUNT'] << count
      end

    end

  end

end
