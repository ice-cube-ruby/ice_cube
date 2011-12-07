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

      def build_ical(builder)
        builder['FREQ'] << 'MINUTELY'
      end

      def build_hash(builder)
        builder.validations[:interval] = interval
      end

      def initialize(interval)
        @interval = interval
      end

      def validate(time, schedule)
        minutes = (time.to_i - schedule.start_time.to_i) / IceCube::ONE_MINUTE
        minutes +=1 if (time.to_i % ONE_MINUTE - schedule.start_time.to_i % ONE_MINUTE) > 0 # bucket
        unless minutes % interval == 0
          interval - (minutes % interval)
        end
      end

    end

  end

end
