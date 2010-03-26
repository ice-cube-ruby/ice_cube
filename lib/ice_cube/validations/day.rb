module DayValidation
  
  # Specify what days of the week this rule should occur on.
  # ie: Schedule.weekly.day_of_week(:monday) would create a rule that
  # occurs every monday.
  def day(*days)
    @days ||= []
    days.each do |day|
      raise ArgumentError.new('Argument must be a valid day of the week') unless DAYS.has_key?(day)
      @days << DAYS[day]
    end
    self
  end
  
  def validate_day(date)
    return true if !@days || @days.empty?
    @days.include?(date.wday)
  end
  
  def closest_day(date)
    return nil if !@days || @days.empty?
    # turn days into distances
    days = @days.map do |d| 
      d > date.wday ? (d - date.wday) : (7 - date.wday + d)
    end
    days.compact!
    # go to the closest distance away, the start of that day
    date + days.min * ONE_DAY
  end
  
end