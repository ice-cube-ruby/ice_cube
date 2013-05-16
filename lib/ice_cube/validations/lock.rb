module IceCube

  # A validation mixin that will lock the +type field to
  # +value or +schedule.start_time.send(type) if value is nil

  module Validations::Lock

    INTERVALS = {:min => 60, :sec => 60, :month => 12, :wday => 7}

    def validate(time, schedule)
      return send(:"validate_#{type}_lock", time, schedule) unless INTERVALS[type]
      start = value || schedule.start_time.send(type)
      start = INTERVALS[type] + start if start < 0 # handle negative values
      start >= time.send(type) ? start - time.send(type) : INTERVALS[type] - time.send(type) + start
    end

    private

    # Lock the hour if explicitly set by hour_of_day, but allow for the nearest
    # hour during DST start to keep the correct interval.
    #
    def validate_hour_lock(time, schedule)
      hour = value || schedule.start_time.send(type)
      hour = 24 + hour if hour < 0
      if hour >= time.hour
        hour - time.hour
      else
        if dst_offset = TimeUtil.dst_change(time)
          hour - time.hour + dst_offset
        else
          24 - time.hour + hour
        end
      end
    end

    # For monthly rules that have no specified day value, the validation relies
    # on the schedule start time and jumps to include every month even if it
    # has fewer days than the schedule's start day.
    #
    # Negative day values (from month end) also include all months.
    #
    # Positive day values are taken literally so months with fewer days will
    # be skipped.
    #
    def validate_day_lock(time, schedule)
      days_in_month = TimeUtil.days_in_month(time)
      date = Date.new(time.year, time.month, time.day)

      if value && value < 0
        start = TimeUtil.day_of_month(value, date)
        month_overflow = days_in_month - TimeUtil.days_in_next_month(time)
      elsif value && value > 0
        start = value
        month_overflow = 0
      else
        start = TimeUtil.day_of_month(schedule.start_time.day, date)
        month_overflow = 0
      end

      sleeps = start - date.day

      if value && value > 0
        until_next_month = days_in_month + sleeps
      else
        until_next_month = start < 28 ? days_in_month : TimeUtil.days_to_next_month(date)
        until_next_month += sleeps - month_overflow
      end

      sleeps >= 0 ? sleeps : until_next_month
    end

  end

end
