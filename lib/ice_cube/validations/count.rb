module IceCube

  module Validations::Count

    # Value reader for limit
    def occurrence_count
      @count
    end

    def count(max)
      unless max.nil? || max.is_a?(Fixnum)
        raise ArgumentError, "Expecting Fixnum or nil value for count, got #{max.inspect}"
      end
      @count = max
      replace_validations_for(:count, max && [Validation.new(max, self)])
      self
    end

    class Validation

      attr_reader :rule, :count

      def initialize(count, rule)
        @count = count
        @rule = rule
      end

      def type
        :limit
      end

      def dst_adjust?
        false
      end

      def validate(time, schedule)
        raise CountExceeded if rule.uses && rule.uses >= count
      end

      def build_s(builder)
        builder.piece(:count) << count
      end

      def build_hash(builder)
        builder[:count] = count
      end

      def build_ical(builder)
        builder['COUNT'] << count
      end

      StringBuilder.register_formatter(:count) do |segments|
        count = segments.first
        IceCube::I18n.t('ice_cube.times', count: count)
      end

    end

  end

end
