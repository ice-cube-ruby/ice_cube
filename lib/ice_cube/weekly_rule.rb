module IceCube

  class WeeklyRule < Rule

    # Specify what days of the week this rule should occur on.
    # ie: Schedule.weekly.day_of_week(:monday) would create a rule that
    # occurs every monday.
    def day_of_week(*days)
      @days_of_week ||= []
      days.each do |day|
        raise ArgumentError.new('Argument must be a valid day of the week') unless DAYS.has_key?(day)
        @days_of_week << DAYS[day]
      end
      self
    end

    # Determine whether or not this rule occurs on a given date.
    # Weekly rules occurs if we're in one of the interval weeks,
    # and we're in a valid day of the week.
    def occurs_on?(date, start_date)
      return false unless validate(date, start_date)
      #check to make sure we're in the right interval
      day_count = (start_date...date).count
      return false unless (day_count / 7) % @interval == 0
      #by default, the days will be the start_date's day of the week
      days_of_week = @days_of_week || [start_date.wday]
      days_of_week.include?(date.wday)
    end

    # a meaningful representation of the rule
    def to_s
      if @days_of_week
        "Every #{@interval} week(s), on (#{@days.join(', ')})"
      else
        "Every #{@interval} week(s)"
      end
    end
    
  end

end
