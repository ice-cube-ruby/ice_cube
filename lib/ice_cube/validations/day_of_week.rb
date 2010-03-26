module DayOfWeekValidation
  
  def self.included(base)
    base::SuggestionTypes << :day_of_week
  end
  
  # Specify the day(s) of the week that this rule should occur
  # on.  ie: rule.day_of_week(:monday => [1, -1]) would mean
  # that this rule should occur on the first and last mondays of each month.
  def day_of_week(days)
    @days_of_week ||= {}
    days.each do |day, occurrences|
      raise ArgumentError.new('Argument must be a valid day') unless DAYS.has_key?(day)
      @days_of_week[DAYS[day]] ||= []
      @days_of_week[DAYS[day]].concat(occurrences)
    end
    self
  end
  
  def validate_day_of_week(date)
    # is it even one of the valid days?
    return true if !@days_of_week || @days_of_week.empty?
    return false unless @days_of_week.has_key?(date.wday) #shortcut
    # does this fall on one of the occurrences?
    first_occurrence = ((7 - Time.utc(date.year, date.month, 1).wday) + date.wday) % 7 + 1 #day of first occurrence of a wday in a month
    this_weekday_in_month_count = ((TimeUtil.days_in_month(date) - first_occurrence + 1) / 7.0).ceil #how many of these in the month
    nth_occurrence_of_weekday = (date.mday - first_occurrence) / 7 + 1 #what occurrence of the weekday is +date+
    @days_of_week[date.wday].include?(nth_occurrence_of_weekday) || @days_of_week[date.wday].include?(nth_occurrence_of_weekday - this_weekday_in_month_count - 1)
  end
  
  #note - temporary implementation
  def closest_day_of_week(date)
    return nil if !@days_of_week || @days_of_week.empty?
    tdate = date.dup
    while tdate += ONE_DAY
      return tdate if validate_day_of_week(tdate)
    end
  end
  
end