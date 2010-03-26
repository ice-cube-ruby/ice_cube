module DayOfMonthValidation
    
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
    
  def validate_day_of_month(date)
    return true if !@days_of_month || @days_of_month.empty?
    @days_of_month.include?(date.mday) || @days_of_month.include?(date.mday - date.days_in_month - 1)
  end
  
  def closest_day_of_month(date)
    return nil if !@days_of_month || @days_of_month.empty?
    #get some variables we need
    days_in_month = date.days_in_month
    days_left_in_this_month = days_in_month - date.mday
    next_month, next_year = date.month == 12 ? [1, date.year + 1] : [date.month + 1, date.year] #clean way to wrap over years
    days_in_next_month = Time.utc(next_year, next_month, 1).days_in_month
    # create a list of distances
    distances = []
    @days_of_month.each do |d|
      if d > 0
        distances << d - date.mday #today is 1, we want 20 (19)
        distances << days_left_in_this_month + d #(364 + 20)
      elsif d < 0
        distances << (days_in_month + d + 1) - date.mday #today is 30, we want -1
        distances << (days_in_next_month + d + 1) + days_left_in_this_month #today is 300, we want -70
      end
    end
    #return the lowest distance
    distances = distances.select { |d| d > 0 }
    return nil if distances.empty?
    # return the start of the proper day
    date + distances.min * ONE_DAY
  end
    
end