module IceCube

  class WeeklyRule < Rule
    
    # Determine whether or not this rule occurs on a given date.
    # Weekly rules occurs if we're in one of the interval weeks,
    # and we're in a valid day of the week.
    def in_interval?(date, start_date)
      #make sure we're in the right interval
      date = adjust(date, start_date)

      date = Date.civil(date.year, date.month, date.day)
      start_date = Date.civil(start_date.year, start_date.month, start_date.day)

      #Move both to the start of their respective weeks,
      #and find the number of full weeks between them
      no_weeks = ((date - date.wday) - (start_date - start_date.wday)) / 7

      no_weeks % @interval == 0
    end
    
    def to_ical 
      'FREQ=WEEKLY' << to_ical_base
    end
    
    def to_s
      to_s_base 'Weekly', "Every #{@interval} weeks"
    end
    
    protected
    
    def default_jump(date, attempt_count = nil)
      goal = date + 7 * IceCube::ONE_DAY * @interval
      adjust(goal, date)
    end

    private

    def initialize(interval)
      super(interval)
    end
     
  end

end
