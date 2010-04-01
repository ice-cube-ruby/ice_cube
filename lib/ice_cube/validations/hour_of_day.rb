module HourOfDayValidation
  
  def self.included(base)
    base::SuggestionTypes << :hour_of_day
  end
  
  def hour_of_day(*hours)
    @validations[:hour_of_day] ||= []
    hours.each do |hour| 
      raise ArgumentError.new('Argument must be a valid hour') unless hour < 24 && hour >= 0
      @validations[:hour_of_day] << hour
    end
    self
  end
  
  def validate_hour_of_day(date)
    return true if !@validations[:hour_of_day] || @validations[:hour_of_day].empty?
    @validations[:hour_of_day].include?(date.hour)
  end
  
  def closest_hour_of_day(date)
    return nil if !@validations[:hour_of_day] || @validations[:hour_of_day].empty?
    # turn hours into hour of day
    # hour >= 24 should fall into the next day
    hours = @validations[:hour_of_day].map do |h|
      h > date.hour ? h - date.hour : 24 - date.hour + h
    end
    hours.compact!
    # go to the closest distance away, the start of that hour
    closest_hour = hours.min
    goal = date + ONE_HOUR * closest_hour
    adjust(goal, date)
  end
  
end