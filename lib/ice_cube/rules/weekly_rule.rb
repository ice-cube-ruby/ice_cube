module IceCube

  class WeeklyRule < ValidatedRule

    include Validations::WeeklyInterval

    attr_reader :week_start

    def initialize(interval = 1, week_start = :sunday)
      super(interval)
      interval(interval, week_start)
      schedule_lock(:wday, :hour, :min, :sec)
      reset
    end

    def wday_offset(step_time, start_time)
      wday_validations = other_interval_validations.select { |v| v.type == :wday }
      return if wday_validations.none?

      interval = base_interval_validation.validate(step_time, start_time).to_i
      offset = wday_validations
        .map { |v| v.validate(step_time, start_time).to_i }
        .reduce(0) { |least, i| i > 0 && i <= interval && (i < least || least == 0) ? i : least }

      7 - TimeUtil.normalize_wday(step_time.wday, week_start) if offset > 0
    end

  end

end
