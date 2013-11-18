module IceCube

  module Validations::HourOfDay

    # Add hour of day validations
    def hour_of_day(*hours)
      hours.flatten.each do |hour|
        unless hour.is_a?(Fixnum)
          raise ArgumentError, "expecting Fixnum value for hour, got #{hour.inspect}"
        end
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

      def build_s(builder)
        builder.piece(:hour_of_day) << StringBuilder.nice_number(hour)
      end

      def build_hash(builder)
        builder.validations_array(:hour_of_day) << hour
      end

      def build_ical(builder)
        builder['BYHOUR'] << hour
      end

      StringBuilder.register_formatter(:hour_of_day) do |segments|
        str = "on the #{StringBuilder.sentence(segments)} "
        str << (segments.size == 1 ? 'hour of the day' : 'hours of the day')
      end

    end

  end

end
