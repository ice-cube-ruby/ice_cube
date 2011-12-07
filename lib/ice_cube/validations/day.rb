module IceCube

  module Validations::Day

    def day(*days)
      days.each do |day|
        day = TimeUtil.symbol_to_day(day) if day.is_a?(Symbol)
        validations_for(:day) << Validation.new(day)
      end
      clobber_base_validations(:wday, :day)
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :day
      alias :value :day

      def initialize(day)
        @day = day
      end

      def build_hash(builder)
        builder.validations_array(:day) << day
      end

      def build_ical(builder)
        builder['BYDAY'] << IcalBuilder.fixnum_to_ical_day(day)
      end

      def type
        :wday
      end

    end

  end

end
