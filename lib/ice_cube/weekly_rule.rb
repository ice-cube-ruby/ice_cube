module IceCube

  class WeeklyRule < DailyRule
    
    # Specify what days of the week this rule should occur on.
    # ie: Schedule.weekly.day_of_week(:monday) would create a rule that
    # occurs every monday.
    def day(*days)
      @days ||= []
      days.each do |day|
        raise ArgumentError.new('Argument must be a valid day of the week') unless DAYS.has_key?(day)
        @days << DAYS[day]
      end
      self
    end

    # Determine whether or not this rule occurs on a given date.
    # Weekly rules occurs if we're in one of the interval weeks,
    # and we're in a valid day of the week.
    def occurs_on?(date, start_date)
      return false unless validate(date, start_date)
      return false unless validate_days(date)
      #by default, the days will be the start_date's day of the week
      unless @days
        return false unless date.wday == start_date.wday
      end
      #check to make sure we're in the right interval
      day_count = (start_date...date).count
      (day_count / 7) % @interval == 0
    end

    # a meaningful representation of the rule
    def to_s
      if @days_of_week
        "Every #{@interval} week(s), on (#{@days.join(', ')})"
      else
        "Every #{@interval} week(s)"
      end
    end

  private
    
    def validate_days(date)
      return true unless @days
      @days.include?(date.wday)
    end
    
  end

end
