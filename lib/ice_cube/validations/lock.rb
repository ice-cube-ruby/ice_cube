module IceCube

  # A validation mixin that will lock the +type field to
  # +value or +schedule.start_time.send(type) if value is nil

  module Validations::Lock

    INTERVALS = {:hour => 24, :min => 60, :sec => 60, :month => 12, :wday => 7}

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
      days_in_month = TimeUtil.days_in_month(time)
      date = time.to_date

      unless value && value < 0
        start = [value || schedule.start_time.day, days_in_month].min
        month_diff = 0
      else
        start = [1 + days_in_month + value, 1].max
        month_diff = TimeUtil.days_in_next_month(time) - days_in_month
      end

      diff = start - date.day
      diff >= 0 ? diff : (date >> 1) - date + diff + month_diff
    end

  end

end
