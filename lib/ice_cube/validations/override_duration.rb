module IceCube

  module Validations::OverrideDuration

    # Value reader for duration
    def duration
      @duration
    end

    def override_duration(duration)
      @duration = duration
      replace_validations_for(:duration, duration.nil? ? nil : [Validation.new(duration)])
      self
    end

    class Validation

      attr_reader :duration

      def initialize(duration)
        @duration = duration
      end

      def type
        :duration
      end

      def dst_adjust?
        false
      end

      # Always valid
      def validate(step_time, schedule)
      end

      # Do nothing, duration does not affect output string
      def build_s(builder)
      end

      def build_hash(builder)
        builder[:duration] = duration
      end

      # Do nothing.Do not export DURATION to ical beacuse it would conflict
      # with DTEND property of schedule (if any)
      def build_ical(builder)
      end

    end

  end

end
