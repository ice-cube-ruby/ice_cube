module IceCube

  module Validations::DayOfMonth

    include Validations::Lock

    def day_of_month(*days)
      days.each do |day|
        validations_for(:day_of_month) << Validation.new(day)
      end
      clobber_base_validations(:day, :wday)
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
        builder.validations_array(:day_of_month) << day
      end

      def build_ical(builder)
        builder['BYMONTHDAY'] << day
      end

      def type
        :day
      end

    end

  end

end
