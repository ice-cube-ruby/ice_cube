module DayOfYearValidation
  
  def self.included(base)
    base::SuggestionTypes << :day_of_year
  end
  
  # Specify what days of the year this rule applies to.
  # ie: Schedule.yearly(2).days_of_year(17, -1) would create a
  # rule which occurs every 17th and last day of every other year.
  # Note: you cannot combine month_of_year and day_of_year in the same rule.
  def day_of_year(*days)
    @days_of_year ||= []
    days.each do |day|
      raise ArgumentError.new('Argument must be a valid day') if day.abs > 366
      raise ArgumentError.new('Argument must be non-zero') if day == 0
      @days_of_year << day
    end
    self
  end
  
  def validate_day_of_year(date)
    return true if !@days_of_year || @days_of_year.empty?
    @days_of_year.include?(date.yday) || @days_of_year.include?(date.yday - TimeUtil.days_in_year(date) - 1)
  end
  
  def closest_day_of_year(date)
    return nil if !@days_of_year || @days_of_year.empty?
    #get some variables we need
    days_in_year = TimeUtil.days_in_year(date)
    days_left_in_this_year = days_in_year - date.yday
    days_in_next_year = TimeUtil.days_in_year(Time.utc(date.year + 1, 1, 1))
    # create a list of distances
    distances = []
    @days_of_year.each do |d|
      if d > 0
        distances << d - date.yday #today is 1, we want 20 (19)
        distances << days_left_in_this_year + d #(364 + 20)
      elsif d < 0
        distances << (days_in_year + d + 1) - date.yday #today is 300, we want -1
        distances << (days_in_next_year + d + 1) + days_left_in_this_year #today is 300, we want -70
      end
    end
    #return the lowest distance
    #TODO - use inject in here and day_of_month
    distances = distances.select { |d| d > 0 }
    return nil if distances.empty?
    # return the start of the proper day
    date + distances.min * ONE_DAY
  end
  
end