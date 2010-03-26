module MonthOfYearValidation
  
  def self.included(base)
    base::SuggestionTypes << :month_of_year
  end
  
  # Specify what months of the year this rule applies to.  
  # ie: Schedule.yearly(2).month_of_year(:january, :march) would create a
  # rule which occurs every january and march, every other year
  # Note: you cannot combine day_of_year and month_of_year in the same rule.
  def month_of_year(*months)
    @months_of_year ||= []
    months.each do |month|
      raise ArgumentError.new('Argument must be a valid month') unless MONTHS.has_key?(month)
      @months_of_year << MONTHS[month]
    end
    self
  end
  
  def validate_month_of_year(date)
    return true if !@months_of_year || @months_of_year.empty?
    @months_of_year.include?(date.month)
  end
  
  def closest_month_of_year(date)
    return nil if !@months_of_year || @months_of_year.empty?
    # turn months into month of year
    # month > 12 should fall into the next year
    months = @months_of_year.map do |m|
      m > date.month ? m : m + 12
    end
    months.compact!
    # go to the closest distance away
    closest_month = months.min
    closest_month < 12 ? Time.utc(date.year, closest_month, date.day, date.hour, date.min, date.sec) : 
                         Time.utc(date.year + 1, closest_month - 12, date.day, date.hour, date.min, date.sec)
  end
  
end