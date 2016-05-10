module IceCube

  module Validations::Until

    extend Deprecated

    # Value reader for limit
    def until_time
      @until
    end
    deprecated_alias :until_date, :until_time

    def until(time)
      time = TimeUtil.ensure_time(time, true)
      @until = time
      replace_validations_for(:until, time.nil? ? nil : [Validation.new(time)])
      self
    end

    class Validation

      attr_reader :time

      def initialize(time)
        @time = time
      end

      def type
        :limit
      end

      def dst_adjust?
        false
      end

      def validate(step_time, schedule)
        raise UntilExceeded if step_time > time
      end

      def build_s(builder)
        date = IceCube::I18n.l(time, format: IceCube.to_s_time_format)
        builder.piece(:until) << IceCube::I18n.t('ice_cube.until', date: date)
      end

      def build_hash(builder)
        builder[:until] = TimeUtil.serialize_time(time)
      end

      def build_ical(builder)
        builder['UNTIL'] << IcalBuilder.ical_utc_format(time)
      end

    end

  end

end
