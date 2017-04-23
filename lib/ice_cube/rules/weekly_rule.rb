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

    # Calculate the effective start time for when the given start time is later
    # in the week than one of the weekday validations, such that times could be
    # missed by a 7-day jump using the weekly interval, or when selecting from a
    # date that is misaligned from the schedule interval.
    #
    def realign(step_time, start_time)
      time = TimeUtil::TimeWrapper.new(start_time)
      offset = wday_offset(step_time, start_time)
      time.add(:day, offset)
      time.to_time
    end

    def wday_offset(step_time, start_time)
      wday_validations = other_interval_validations.select { |v| v.type == :wday }
      return 0 if wday_validations.none?

      days = (step_time - start_time).to_i / ONE_DAY
      interval = base_interval_validation.validate(step_time, start_time).to_i
      min_wday = TimeUtil.normalize_wday(wday_validations.min_by(&:day).day, week_start)
      step_wday = TimeUtil.normalize_wday(step_time.wday, week_start)

      days + interval - step_wday + min_wday
    end

  end

end
