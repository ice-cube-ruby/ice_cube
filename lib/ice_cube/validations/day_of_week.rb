module IceCube

  module Validations::DayOfWeek

    def day_of_week(dows)
      dows.each do |day, occs|
        occs.each do |occ|
          day = TimeUtil.symbol_to_day(day) if day.is_a?(Symbol)
          validations_for(:day_of_week) << Validation.new(day, occ)
        end
      end
      clobber_base_validations :day, :wday
      self
    end

    class Validation

      attr_reader :day, :occ

      def type
        :day
      end

      def build_ical(builder)
        ical_day = IcalBuilder.fixnum_to_ical_day(day)
        builder['BYDAY'].delete_if { |d| d == ical_day }
        builder['BYDAY'] << "#{occ}#{IcalBuilder.fixnum_to_ical_day(day)}"
      end

      def initialize(day, occ)
        @day = day
        @occ = occ
      end

      def validate(time, schedule)
        # count the days to the weekday
        sum = day >= time.wday ? day - time.wday : 7 - time.wday + day
        time += sum * ONE_DAY
        # and then count the week until a viable occ
        loop do
          which_occ, num_occ = TimeUtil.which_occurrence_in_month(time, day)
          this_occ = occ < 0 ? num_occ + occ + 1 : occ
          break if which_occ == this_occ
          sum += 7
          time += ONE_WEEK
        end
        sum
      end

    end

  end

end
