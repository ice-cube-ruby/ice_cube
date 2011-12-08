module IceCube

  module Validations::DailyInterval

    # Add a new interval validation
    def interval(interval)
      validations_for(:interval) << Validation.new(interval)
      clobber_base_validations(:wday, :day)
      self
    end

    # A validation for checking to make sure that a time
    # is inside of a certain DailyInterval
    class Validation

      attr_reader :interval

      def initialize(interval)
        @interval = interval
      end

      def build_s(builder)
        builder.base = interval == 1 ? 'Daily' : "Every #{interval} days"
      end

      def build_hash(builder)
        builder.validations[:interval] = interval
      end

      def build_ical(builder)
        builder['FREQ'] << 'DAILY'
      end

      def type
        :day
      end

      def validate(time, schedule)
        # TODO check no AR dependence (in 1.8.7 also)
        # TODO do something similar to other buckets or try to remove them
        days = time.to_date - schedule.start_time.to_date
        unless days % interval === 0
          interval - (days % interval)
        end
      end

    end

  end

end
