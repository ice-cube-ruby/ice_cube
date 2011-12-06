module IceCube

  module Validations::YearlyInterval

    def interval(interval = 1)
      validations_for(:interval) << Validation.new(interval)
      clobber_base_validations(:year)
    end

    class Validation

      attr_reader :interval

      def type
        :year
      end

      def initialize(interval)
        @interval = interval
      end

      def validate(time, schedule)
        years_to_start = time.year - schedule.start_time.year
        unless years_to_start % interval == 0
          interval - (years_to_start % interval)
        end
      end

    end

  end

end
