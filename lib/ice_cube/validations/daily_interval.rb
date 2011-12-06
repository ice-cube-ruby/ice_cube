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

      def type
        :day
      end

      def validate(time, schedule)
        days = (time.to_i - schedule.start_time.to_i) / ONE_DAY
        days += 1 if (time.to_i % ONE_DAY - schedule.start_time.to_i % ONE_DAY) > 0 # bucket 
        unless days % interval === 0
          interval - (days % interval)
        end
      end

    end

  end

end
