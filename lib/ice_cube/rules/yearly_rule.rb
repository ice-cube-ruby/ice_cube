module IceCube

  class YearlyRule < Rule
    
    # Determine whether or not the rule, given a start_date,
    # occurs on a given date.
    # Yearly occurs if we're in a proper interval
    # and either (1) we're on a day of the year, or (2) we're on a month of the year as specified
    # Note: rollover dates don't work, so you can't ask for the 400th day of a year
    # and expect to roll into the next year (this might be a possible direction in the future)
    def in_interval?(date, start_date)
      #make sure we're in the proper interval
      (date.year - start_date.year) % @interval == 0
    end
    
    def to_ical 
      'FREQ=YEARLY' << to_ical_base
    end
    
    protected
    
    def default_jump(date)
      Time.utc(date.year + @interval, date.month, date.day, date.hour, date.min, date.sec)
    end
    
    private

    def initialize(interval)
      super(interval)
    end
    
  end
    
end
