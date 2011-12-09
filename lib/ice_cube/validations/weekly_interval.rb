require 'date'

module IceCube

  module Validations::WeeklyInterval

    def interval(interval)
      validations_for(:interval) << Validation.new(interval)
      clobber_base_validations(:day)
    end

    class Validation

      attr_reader :interval

      def type
        :day
      end

      def build_s(builder)
        builder.base = interval == 1 ? 'Weekly' : "Every #{interval} weeks"
      end

      def build_ical(builder)
        builder['FREQ'] << 'WEEKLY'
      end

      def build_hash(builder)
        builder[:interval] = interval
      end

      def initialize(interval)
        @interval = interval
      end

      def validate(time, schedule)
        date = Date.new(time.year, time.month, time.day)
        st = schedule.start_time
        start_date = Date.new(st.year, st.month, st.day)
        weeks = ((date - date.wday) - (start_date - start_date.wday)) / 7
        unless weeks % interval == 0
          (interval - (weeks % interval)) * 7
        end
      end

    end

  end

end
