module IceCube

  module Validations::SecondlyInterval

    def interval(interval)
      @interval = interval
      replace_validations_for(:interval, [Validation.new(interval)])
      clobber_base_validations(:sec)
      self
    end

    class Validation

      attr_reader :interval

      def initialize(interval)
        @interval = interval
      end

      def type
        :sec
      end

      def dst_adjust?
        false
      end

      def validate(time, schedule)
        seconds = time.to_i - schedule.start_time.to_i
        unless seconds % interval == 0
          interval - (seconds % interval)
        end
      end

      def build_s(builder)
        builder.base = interval == 1 ? 'Secondly' : "Every #{interval} seconds"
      end

      def build_ical(builder)
        builder['FREQ'] << 'SECONDLY'
        builder['INTERVAL'] << interval unless interval == 1
      end

      def build_hash(builder)
        builder[:interval] = interval
      end

    end

  end

end
