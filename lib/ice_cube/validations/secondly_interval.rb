module IceCube

  module Validations::SecondlyInterval

    def interval(interval)
      validations_for(:interval) << Validation.new(interval)
      clobber_base_validations(:sec)
      self
    end

    class Validation

      attr_reader :interval

      def type
        :sec
      end

      def initialize(interval)
        @interval = interval
      end

      def validate(time, schedule)
        seconds = time.sec - schedule.start_time.sec
        unless seconds % interval == 0
          seconds - (seconds % interval)
        end
      end

    end

  end

end
