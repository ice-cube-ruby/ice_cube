module IceCube

  module Validations::SecondOfMinute

    def second_of_minute(*seconds)
      seconds.each do |second|
        validations_for(:second_of_minute) << Validation.new(second)
      end
      clobber_base_validations :sec
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :second
      alias :value :second

      def initialize(second)
        @second = second
      end

      def type
        :sec
      end

      def build_ical(builder)
        builder['BYSECOND'] << second
      end

    end

  end

end
