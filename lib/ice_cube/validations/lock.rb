module IceCube

  # A validation mixin that will lock the +type field to
  # +value or +schedule.start_time.send(type) if value is nil

  module Validations::Lock

    INTERVALS = { :hour => 24, :min => 60, :sec => 60, :month => 12, :wday => 7 }
    def validate(time, schedule)
      return send(:"validate_#{type}_lock", time, schedule) unless INTERVALS[type]
      start = value || schedule.start_time.send(type)
      start = INTERVALS[type] + start if start < 0 # handle negative values
      start >= time.send(type) ? start - time.send(type) : INTERVALS[type] - time.send(type) + start
    end

    private

    # Needs to be custom since we don't know the days in the month
    # (meaning, its not a fixed interval)
    def validate_day_lock(time, schedule)
      start = value || schedule.start_time.day
      days_in_month = TimeUtil.days_in_month(time)
      start = days_in_month + start + 1 if start < 0 # handle negatives
      start >= time.day ? start - time.day : days_in_month - time.day + start
    end

  end

end
