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
        hours = time.hour - schedule.start_time.hour
        unless hours % interval == 0
          interval - (hours % interval)
        end
      end

    end

  end

end
