module IceCube

  class MonthlyRule < ValidatedRule

    include Validations::HourOfDay
    include Validations::MinuteOfHour
    include Validations::SecondOfMinute
    include Validations::DayOfMonth
    include Validations::DayOfWeek
    include Validations::Day
    include Validations::MonthOfYear
    # include Validations::DayOfYear    # n/a

    include Validations::MonthlyInterval

    def initialize(interval = 1)
      super
      interval(interval)
      schedule_lock(:day, :hour, :min, :sec)
      reset
    end

    def verify_alignment(value, freq, rule_part)
      return unless freq == :month
      return unless @validations[:interval]

      interval_validation = @validations[:interval].first
      interval_value = (rule_part == :interval) ? value : interval_validation.interval
      return if interval_value == 1 || (interval_value % 12).zero?
      return if other_fixed_value_validations.empty?

      message = "month_of_year can only be used with interval(1) or multiples of interval(12)"
      yield ArgumentError.new(message)
    end

  end

end
