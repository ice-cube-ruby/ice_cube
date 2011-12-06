module IceCube

  module Validations::HourlyInterval

    def interval(interval)
      validations_for(:interval) << Validation.new(interval)
      clobber_base_validations(:hour)
      self
    end 

    class Validation

      attr_reader :interval

      def type
        :hour
      end

      def initialize(interval)
        @interval = interval
      end

      def validate(time, schedule)
        hours = (time.to_i - schedule.start_time.to_i) / IceCube::ONE_HOUR
        hours += 1 if (time.to_i % ONE_HOUR - schedule.start_time.to_i % ONE_HOUR) > 0 # bucket 
        unless hours % interval == 0
          interval - (hours % interval)
        end
      end

    end

  end

end
