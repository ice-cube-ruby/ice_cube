module MonthOfYearValidation
  
  def self.included(base)
    base::SuggestionTypes << :month_of_year
  end
  
  # Specify what months of the year this rule applies to.  
  # ie: Schedule.yearly(2).month_of_year(:january, :march) would create a
  # rule which occurs every january and march, every other year
  # Note: you cannot combine day_of_year and month_of_year in the same rule.
  def month_of_year(*months)
    @validations[:month_of_year] ||= []
    months.each do |month|
      raise ArgumentError.new('Argument must be a valid month') unless MONTHS.has_key?(month)
      @validations[:month_of_year] << MONTHS[month]
    end
    self
  end
  
  def validate_month_of_year(date)
    return true if !@validations[:month_of_year] || @validations[:month_of_year].empty?
    @validations[:month_of_year].include?(date.month)
  end
  
  def closest_month_of_year(date)
    return nil if !@validations[:month_of_year] || @validations[:month_of_year].empty?
    # turn months into month of year
    # month > 12 should fall into the next year
    months = @validations[:month_of_year].map do |m|
      m > date.month ? m - date.month : 12 - date.month + m
    end
    months.compact!
    # go to the closest distance away
    goal = date
    months.min.times { goal += TimeUtil.days_in_month(goal) * ONE_DAY }
    adjust(goal, date)
  end
  
end