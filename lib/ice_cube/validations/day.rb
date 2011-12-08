require 'date'

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

      def build_s(builder)
        builder.piece(:day) << "#{Date::DAYNAMES[day]}s"
      end

      def build_hash(builder)
        builder.validations_array(:day) << day
      end

      def build_ical(builder)
        ical_day = IcalBuilder.fixnum_to_ical_day(day)
        # Only add if there aren't others from day_of_week that override
        if builder['BYDAY'].none? { |b| b.end_with?(ical_day) }
          builder['BYDAY'] << ical_day
        end
      end

      def type
        :wday
      end

      StringBuilder.register_formatter(:day) do |segments|
        "on #{StringBuilder.sentence(segments)}"
      end

    end

  end

end
