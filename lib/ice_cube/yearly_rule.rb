module IceCube

  class YearlyRule < MonthlyRule

    # Specify what months of the year this rule applies to.  
    # ie: Schedule.yearly(2).month_of_year(:january, :march) would create a
    # rule which occurs every january and march, every other year
    # Note: you cannot combine day_of_year and month_of_year in the same rule.
    def month_of_year(*months)
      raise ArgumentError.new('Cannot specify month_of_year AND day_of_year') if @days_of_year
      @months_of_year ||= []
      months.each do |month|
        raise ArgumentError.new('Argument must be a valid month') unless MONTHS.has_key?(month)
        @months_of_year << MONTHS[month]
      end
      self
    end

    # Specify what days of the year this rule applies to.
    # ie: Schedule.yearly(2).days_of_year(17, -1) would create a
    # rule which occurs every 17th and last day of every other year.
    # Note: you cannot combine month_of_year and day_of_year in the same rule.
    def day_of_year(*days)
      raise ArgumentError.new('Cannot specify month_of_year AND day_of_year') if @months_of_year
      @days_of_year ||= []
      days.each do |day|
        raise ArgumentError.new('Argument must be a valid day') if day.abs > 366
        raise ArgumentError.new('Argument must be non-zero') if day == 0
        @days_of_year << day
      end
      self
    end
    
    # Determine whether or not the rule, given a start_date,
    # occurs on a given date.
    # Yearly occurs if we're in a proper interval
    # and either (1) we're on a day of the year, or (2) we're on a month of the year as specified
    # Note: rollover dates don't work, so you can't ask for the 400th day of a year
    # and expect to roll into the next year (this might be a possible direction in the future)
    def occurs_on?(date, start_date)
      return false unless validate(date, start_date)
      return false unless validate_days(date)
      return false unless validate_days_of_year(date)
      return false unless validate_days_of_week(date)
      return false unless validate_days_of_month(date)
      return false unless validate_months_of_year(date)
      # if only months of year is specified, it should only return the single day of start_date
      unless @days_of_year || @days_of_month || @days_of_week || @days
        return false unless date.day == start_date.day
      end
      # fall back on making sure that the day falls on this exact day of the year
      unless @months_of_year || @days_of_year || @days_of_week || @days_of_month || @days
        return false unless date.month == start_date.month && date.day == start_date.day
      end
      #make sure we're in the proper interval
      (date.year - start_date.year) % @interval == 0
    end

    # Create a meaningful string representation of the rule
    def to_s
      beginning = "Every #{@interval} year(s)"
      if @days_of_year
        "#{beginning}, on (#{@days_of_year.join(', ')})"
      elsif @months_of_year
        "#{beginning}, in (#{@months_of_year.join(', ')})"
      else
        beginning
      end
    end

  private

    def validate_months_of_year(date)
      return true unless @months_of_year
      @months_of_year.include?(date.month)
    end

    def validate_days_of_year(date)
      return true unless @days_of_year
      days_in_year = Date.civil(date.year, 12, -1).yday
      @days_of_year.include?(date.yday) || @days_of_year.include?(date.yday - days_in_year - 1)
    end
    
  end
    
end
