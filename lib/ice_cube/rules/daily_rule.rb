module IceCube

  class DailyRule < ValidatedRule

    include Validations::DailyInterval

    def initialize(interval = 1)
      super
      interval(interval)
      schedule_lock(:hour, :min, :sec)
      reset
    end

    def verify_alignment(value, freq, rule_part)
      return unless freq == :wday || freq == :day
      return unless @validations[:interval]

      interval_validation = @validations[:interval].first
      interval_value = (rule_part == :interval) ? value : interval_validation.interval
      return if interval_value == 1

      if freq == :wday
        return if (interval_value % 7).zero?
        return if Array(@validations[:day]).empty?
        message = "day can only be used with multiples of interval(7)"
      else
        (fixed_validation = other_fixed_value_validations.first) or return
        message = "#{fixed_validation.key} can only be used with interval(1)"
      end

      yield ArgumentError.new(message)
    end

  end

end
