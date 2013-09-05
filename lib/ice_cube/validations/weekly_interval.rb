require 'date'

module IceCube

  module Validations::WeeklyInterval

    def interval(interval, week_start = :sunday)
      @interval = interval
      @week_start = TimeUtil.wday_to_sym(week_start)
      replace_validations_for(:interval, [Validation.new(interval, week_start)])
      clobber_base_validations(:day)
      self
    end

    def week_start
      @week_start
    end

    class Validation

      attr_reader :interval, :week_start

      def type
        :day
      end

      def build_s(builder)
        builder.base = interval == 1 ? 'Weekly' : "Every #{interval} weeks"
      end

      def build_ical(builder)
        builder['FREQ'] << 'WEEKLY'
        unless interval == 1
          builder['INTERVAL'] << interval
          builder['WKST'] << week_start.to_s.upcase[0..1]
        end
      end

      def build_hash(builder)
        builder[:interval] = interval
        builder[:week_start] = TimeUtil.sym_to_wday(week_start)
      end

      def initialize(interval, week_start)
        @interval = interval
        @week_start = week_start
      end

      def validate(time, schedule)
        raise ZeroInterval if interval == 0
        date = Date.new(time.year, time.month, time.day)
        st = schedule.start_time
        start_date = Date.new(st.year, st.month, st.day)
        weeks = (
          (date - TimeUtil.normalize_wday(date.wday, week_start)) -
          (start_date - TimeUtil.normalize_wday(start_date.wday, week_start))
        ) / 7
        unless weeks % interval == 0
          (interval - (weeks % interval)) * 7
        end
      end

    end

  end

end
