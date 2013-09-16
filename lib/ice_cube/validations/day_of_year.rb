module IceCube

  module Validations::DayOfYear

    def day_of_year(*days)
      days.flatten.each do |day|
        unless day.is_a?(Fixnum)
          raise ArgumentError, "expecting Fixnum value for day, got #{day.inspect}"
        end
        validations_for(:day_of_year) << Validation.new(day)
      end
      clobber_base_validations(:month, :day, :wday)
      self
    end

    class Validation

      attr_reader :day

      StringBuilder.register_formatter(:day_of_year) do |entries|
        str = "#{I18n.t('ice_cube.on')} #{I18n.t('ice_cube.the')} #{StringBuilder.sentence(entries)} "
        str << I18n.t('ice_cube.days_of_year', count: entries.size)
        str
      end

      def initialize(day)
        @day = day
      end

      def type
        :day
      end

      def build_s(builder)
        builder.piece(:day_of_year) << StringBuilder.nice_number(day)
      end

      def build_hash(builder)
        builder.validations_array(:day_of_year) << day
      end

      def build_ical(builder)
        builder['BYYEARDAY'] << day
      end

      def validate(time, schedule)
        days_in_year = TimeUtil.days_in_year(time)
        the_day = day < 0 ? day + days_in_year : day
        # compute the diff
        diff = the_day - time.yday
        diff >= 0 ? diff : diff + days_in_year
      end

    end

  end

end
