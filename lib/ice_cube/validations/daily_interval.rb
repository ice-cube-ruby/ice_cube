module IceCube

  module Validations::DailyInterval

    # Add a new interval validation
    def interval(interval)
      @interval = interval
      replace_validations_for(:interval, [Validation.new(interval)])
      clobber_base_validations(:wday, :day)
      self
    end

    class Validation

      attr_reader :interval

      def initialize(interval)
        @interval = interval
      end

      def type
        :day
      end

      def dst_adjust?
        true
      end

      def build_s(builder)
        builder.base = interval == 1 ? 'Daily' : "Every #{interval} days"
      end

      def build_hash(builder)
        builder[:interval] = interval
      end

      def build_ical(builder)
        builder['FREQ'] << 'DAILY'
        builder['INTERVAL'] << interval unless interval == 1
      end

      def validate(time, schedule)
        raise ZeroInterval if interval == 0
        time_date = Date.new(time.year, time.month, time.day)
        start_date = Date.new(schedule.start_time.year, schedule.start_time.month, schedule.start_time.day)
        days = time_date - start_date
        unless days % interval === 0
          interval - (days % interval)
        end
      end

    end

  end

end
