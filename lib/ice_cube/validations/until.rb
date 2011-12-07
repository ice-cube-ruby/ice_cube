module IceCube

  module Validations::Until

    # accessor
    def until_time
      @until
    end
    alias :until_date :until_time

    def until(time)
      @until = time
      replace_validations_for(:until, [Validation.new(time)])
      self
    end

    class Validation

      attr_reader :time

      def initialize(time)
        @time = time
      end

      def build_ical(builder)
        builder['UNTIL'] << IcalBuilder.ical_utc_format(time)
      end

      def build_hash(builder)
        builder[:until] = TimeUtil.serialize_time(time)
      end

      def validate(t, schedule)
        raise UntilExceeded if t > time 
      end

    end
      
  end

end
