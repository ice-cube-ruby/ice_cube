module IceCube

  module Validations::DailyInterval

    # Add a new interval validation
    def interval(interval)
      @interval = normalized_interval(interval)
      replace_validations_for(:interval, [Validation.new(@interval)])
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

      def validate(step_time, schedule)
        t0, t1 = schedule.start_time, step_time
        days = Date.new(t1.year, t1.month, t1.day) -
               Date.new(t0.year, t0.month, t0.day)
        offset = (days % interval).nonzero?
        interval - offset if offset
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

    end

  end

end
