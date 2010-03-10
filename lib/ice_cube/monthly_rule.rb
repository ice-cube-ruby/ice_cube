module IceCube

  class MonthlyRule < Rule

    # Specify the days of the month that this rule should
    # occur on.  ie: rule.day_of_month(1, -1) would mean that
    # this rule should occur on the first and last day of every month.
    def day_of_month(*days)
      @days_of_month ||= []
      days.each do |day|
        raise ArgumentError.new('Argument must be a valid date') if day.abs > 31 
        raise ArgumentError.new('Argument must be non-zero') if day == 0
        @days_of_month << day
      end
      self
    end

    # Specify the day(s) of the week that this rule should occur
    # on.  ie: rule.day_of_week(:monday => [1, -1]) would mean
    # that this rule should occur on the first and last mondays of each month.
    def day_of_week(days)
      @days_of_week ||= {}
      days.each do |day, occurrences|
        raise ArgumentError.new('Argument must be a valid day') unless DAYS.has_key?(day)
        @days_of_week[DAYS[day]] ||= []
        @days_of_week[DAYS[day]] += occurrences #TODO - change to concat
      end
      self
    end

    # Determine for a given date/start_date if this rule occurs or not.
    # Month rules occur if we're in a valid interval
    # and either (1) we're on a valid day of the week (ie: first sunday of the month)
    # or we're on a valid day of the month (1, 15, -1)
    # Note: Rollover is not implemented, so the 35th day of the month is invalid.
    def occurs_on?(date, start_date) 
      return false unless validate(date, start_date)
      number_of_days_in_month = Date.civil(date.year, date.month, -1).day
      # make sure the day in questions falls on a proper day of the week
      if @days_of_week
        return false unless @days_of_week.has_key?(date.wday)
        first_occurrence = ((7 - Date.civil(date.year, date.month, 1).wday) + date.wday) % 7 + 1 #day of first occurrence of a wday in a month
        this_weekday_in_month_count = ((number_of_days_in_month - first_occurrence + 1) / 7.0).ceil #how many of these in the month
        nth_occurrence_of_weekday = (date.mday - first_occurrence) / 7 + 1 #what occurrence of the weekday is +date+
        return false unless @days_of_week[date.wday].include?(nth_occurrence_of_weekday) || @days_of_week[date.wday].include?(nth_occurrence_of_weekday - this_weekday_in_month_count - 1)
      end
      # make sure the day in question falls on a proper day of the month
      if @days_of_month
        return false unless @days_of_month.include?(date.mday - number_of_days_in_month - 1) || @days_of_month.include?(date.mday)
      end
      # if we haven't performed any other validations, perform the default validation
      # which is to make sure that the day falls on the same day of the month as the start_date
      unless @days_of_month || @days_of_week
        return false unless date.mday == [start_date.mday, number_of_days_in_month].min #TODO - rethink?
      end
      #make sure we're in the proper interval
      months_to_start_date = (date.month - start_date.month) + (date.year - start_date.year) * 12
      months_to_start_date % @interval == 0
    end

    def to_s
      if @days_of_week
        "Every #{@interval} month(s) on (#{@days_of_week.join(', ')})"
      else
        "Every #{@interval} month(s) on the (#{@days_of_month.join(', ')}) day(s)"
      end
    end
    
  end

end
