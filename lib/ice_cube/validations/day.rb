module DayValidation
  
  def self.included(base)
    base::SuggestionTypes << :day
  end
  
  # Specify what days of the week this rule should occur on.
  # ie: Schedule.weekly.day_of_week(:monday) would create a rule that
  # occurs every monday.
  def day(*days)
    @validations[:day] ||= []
    days.each do |day|
      raise ArgumentError.new('Argument must be a valid day of the week') unless IceCube::DAYS.has_key?(day)
      @validations[:day] << IceCube::DAYS[day]
    end
    self
  end
  
  def validate_day(date)
    return true if !@validations[:day] || @validations[:day].empty?
    @validations[:day].include?(date.wday)
  end
  
  def closest_day(date)
    return nil if !@validations[:day] || @validations[:day].empty?
    # turn days into distances
    days = @validations[:day].map do |d| 
      d > date.wday ? (d - date.wday) : (7 - date.wday + d)
    end
    days.compact!
    # go to the closest distance away, the start of that day
    goal = date + days.min * IceCube::ONE_DAY
    adjust(goal, date)
  end
  
end