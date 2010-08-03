module TimeUtil
  
  LeapYearMonthDays	=	[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  CommonYearMonthDays	=	[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  # this method exists because ActiveSupport will serialize
  # TimeWithZone's in collections in UTC time instead of
  # their local time.  if +time+ is a TimeWithZone, we move
  # it to a DateTime
  # Note: When converting to datetime, you microseconds get set to 0
  def self.serializable_time(time)
    if time.respond_to?(:to_datetime)
      time.to_datetime
    else
      time
    end
  end
  
  # TODO can we improve this more?
  def self.date_in_n_months(date, month_distance)

    next_mark = date
    days_in_month_of_next_mark = days_in_month(next_mark)
    
    month_distance.times do

      prev_mark = next_mark
      next_mark = next_mark + days_in_month_of_next_mark * ONE_DAY
      
      months_covered = next_mark.month - prev_mark.month

      # step back to the end of the previous month of months_covered went too far
      if months_covered == 2
        next_mark -= next_mark.mday * ONE_DAY
      end

      days_in_month_of_next_mark = days_in_month(next_mark)
      
    end

    # at the end, there's a chance we're not on the correct day,
    # but if we're not - we will always be behind it in the correct month
    # if there exists no proper day in the month for us, return nil - otherwise, return that date

    if days_in_month_of_next_mark >= date.mday
      next_mark += (date.mday - next_mark.mday) * ONE_DAY
      adjust(next_mark, date)
    end
    
  end

  def adjust(goal, date)
    return goal if goal.utc_offset == date.utc_offset
    goal - goal.utc_offset + date.utc_offset
  end
  
  def self.is_leap?(date)
    (date.year % 4 == 0 && date.year % 100 != 0) || (date.year % 400 == 0)
  end

  def self.days_in_year(date)
    is_leap?(date) ? 366 : 365
  end

  def self.days_in_month(date)
    is_leap?(date) ? LeapYearMonthDays[date.month - 1] : CommonYearMonthDays[date.month - 1]
  end

  def self.ical_format(time)
    if time.utc?
      ":#{time.strftime('%Y%m%dT%H%M%SZ')}" # utc time
    else
      ";TZID=#{time.strftime('%Z:%Y%m%dT%H%M%S')}" # local time specified
    end
  end

  def self.ical_duration(duration)
    hours = duration / 3600; duration %= 3600
    minutes = duration / 60; duration %= 60
    repr = ''
    repr << "#{hours}H" if hours > 0
    repr << "#{minutes}M" if minutes > 0
    repr << "#{duration}S" if duration > 0
    "PT#{repr}"
  end
  
end
