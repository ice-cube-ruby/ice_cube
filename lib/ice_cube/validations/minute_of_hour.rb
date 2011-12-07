module IceCube

  module Validations::MinuteOfHour

    include Validations::Lock

    def minute_of_hour(*minutes)
      minutes.each do |minute|
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

      def build_ical(builder)
        builder['BYMINUTE'] << minute
      end

    end

  end

end
