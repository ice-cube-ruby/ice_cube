module IceCube

  module Validations::MinutelyInterval

    def interval(interval)
      validations_for(:interval) << Validation.new(interval)
      clobber_base_validations(:min)
      self
    end

    class Validation

      attr_reader :interval

      def type
        :min
      end

      def initialize(interval)
        @interval = interval
      end

      def validate(time, schedule)
        minutes = time.min - schedule.start_time.min
        unless minutes % interval == 0
          interval - (minutes % interval)
        end
      end

    end

  end

end
