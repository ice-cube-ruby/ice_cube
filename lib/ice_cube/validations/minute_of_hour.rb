module IceCube

  module Validations::MinuteOfHour

    def minute_of_hour(*minutes)
      minutes.flatten.each do |minute|
        unless minute.is_a?(Fixnum)
          raise ArgumentError, "expecting Fixnum value for minute, got #{minute.inspect}"
        end
        validations_for(:minute_of_hour) << Validation.new(minute)
      end
      clobber_base_validations(:min)
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :minute
      alias :value :minute

      def initialize(minute)
        @minute = minute
      end

      def type
        :min
      end

      def dst_adjust?
        false
      end

      def build_s(builder)
        builder.piece(:minute_of_hour) << StringBuilder.nice_number(minute)
      end

      def build_hash(builder)
        builder.validations_array(:minute_of_hour) << minute
      end

      def build_ical(builder)
        builder['BYMINUTE'] << minute
      end

      StringBuilder.register_formatter(:minute_of_hour) do |segments|
        str = "on the #{StringBuilder.sentence(segments)} "
        str << (segments.size == 1 ? 'minute of the hour' : 'minutes of the hour')
      end

    end

  end

end
