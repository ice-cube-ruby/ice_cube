module IceCube

  module TimeUtil
    
    LeapYearMonthDays	=	[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    CommonYearMonthDays	=	[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    def self.serialize_time(time)
      if time.is_a?(ActiveSupport::TimeWithZone)
        { :time => time, :zone => time.time_zone.name }
      elsif time.is_a?(Time)
        time
      end
    end
    
    def self.deserialize_time(time_or_hash) 
      return time_or_hash if time_or_hash.is_a?(Time) # for backward-compat
      if time_or_hash.is_a?(Hash)
        time_or_hash[:time].in_time_zone(time_or_hash[:zone])
      end
    end

    # TODO can we improve this more?
    def self.date_in_n_months(date, month_distance)
      
      next_mark = date
      days_in_month_of_next_mark = days_in_month(next_mark)
      
      month_distance.times do
        
        prev_mark = next_mark
        next_mark += days_in_month_of_next_mark * IceCube::ONE_DAY
        
        # only moving one day at a time, so this suffices
        months_covered = next_mark.month - prev_mark.month
        months_covered += 12 if months_covered < 0
        
        # step back to the end of the previous month of months_covered went too far
        if months_covered == 2
          next_mark -= next_mark.mday * IceCube::ONE_DAY
        end
        
        days_in_month_of_next_mark = days_in_month(next_mark)
        next_mark = adjust(next_mark, prev_mark)
        
      end
      
      # at the end, there's a chance we're not on the correct day,
      # but if we're not - we will always be behind it in the correct month
      # if there exists no proper day in the month for us, return nil - otherwise, return that date
      
      if days_in_month_of_next_mark >= date.mday
        next_mark += (date.mday - next_mark.mday) * IceCube::ONE_DAY
      end
      
    end
    
    def self.adjust(goal, date)
      return goal if goal.utc_offset == date.utc_offset
      goal - goal.utc_offset + date.utc_offset
    end
    
    def self.is_leap?(year)
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    end
    
    def self.days_in_year(date)
      is_leap?(date.year) ? 366 : 365
    end
    
    def self.days_in_month(date)
      is_leap?(date.year) ? LeapYearMonthDays[date.month - 1] : CommonYearMonthDays[date.month - 1]
    end
    
    def self.ical_utc_format(time)
      time = time.dup.utc
      "#{time.strftime('%Y%m%dT%H%M%SZ')}" # utc time
    end
 
    def self.ical_format(time, force_utc)
      time = time.dup.utc if force_utc
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

end
