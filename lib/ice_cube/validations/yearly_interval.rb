module IceCube

  module Validations::YearlyInterval

    def interval(interval)
      @interval = interval
      replace_validations_for(:interval, [Validation.new(interval)])
      clobber_base_validations(:year)
    end

    class Validation

      attr_reader :interval

      def initialize(interval)
        @interval = interval
      end

      def type
        :year
      end

      def validate(step_time, schedule)
        years = step_time.year - schedule.start_time.year
        offset = (years % interval).nonzero?
        interval - offset if offset
      end

      def build_s(builder)
        builder.base = interval == 1 ? 'Yearly' : "Every #{interval} years"
      end

      def build_hash(builder)
        builder[:interval] = interval
      end

      def build_ical(builder)
        builder['FREQ'] << 'YEARLY'
        unless interval == 1
          builder['INTERVAL'] << interval
        end
      end

    end

  end

end
