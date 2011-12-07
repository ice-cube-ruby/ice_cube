module IceCube

  module Validations::HourOfDay

    include Validations::Lock

    # Add hour of day validations
    def hour_of_day(*hours)
      hours.each do |hour|
        validations_for(:hour_of_day) << Validation.new(hour)
      end
      clobber_base_validations(:hour)
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :hour
      alias :value :hour

      def initialize(hour)
        @hour = hour
      end

      def type
        :hour
      end

      def build_hash(builder)
        builder.validations_array(:hour_of_day) << hour
      end

      def build_ical(builder)
        builder['BYHOUR'] << hour
      end

    end

  end

end
