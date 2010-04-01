module DayOfMonthValidation
    
  def self.included(base)
    base::SuggestionTypes << :day_of_month
  end
    
  # Specify the days of the month that this rule should
  # occur on.  ie: rule.day_of_month(1, -1) would mean that
  # this rule should occur on the first and last day of every month.
  def day_of_month(*days)
    @validations[:day_of_month] ||= []
    days.each do |day|
      raise ArgumentError.new('Argument must be a valid date') if day.abs > 31 
      raise ArgumentError.new('Argument must be non-zero') if day == 0
      @validations[:day_of_month] << day
    end
    self
  end
    
  def validate_day_of_month(date)
    return true if !@validations[:day_of_month] || @validations[:day_of_month].empty?
    @validations[:day_of_month].include?(date.mday) || @validations[:day_of_month].include?(date.mday - TimeUtil.days_in_month(date) - 1)
  end
  
  def closest_day_of_month(date)
    return nil if !@validations[:day_of_month] || @validations[:day_of_month].empty?
    #get some variables we need
    days_in_month = TimeUtil.days_in_month(date)
    days_left_in_this_month = days_in_month - date.mday
    next_month, next_year = date.month == 12 ? [1, date.year + 1] : [date.month + 1, date.year] #clean way to wrap over years
    days_in_next_month = TimeUtil.days_in_month(Time.utc(next_year, next_month, 1))
    # create a list of distances
    distances = []
    @validations[:day_of_month].each do |d|
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
    goal = date + distances.min * ONE_DAY
    adjust(goal, date)
  end
    
end