module IceCube

  class MonthlyRule < Rule

    # Determine for a given date/start_date if this rule occurs or not.
    # Month rules occur if we're in a valid interval
    # and either (1) we're on a valid day of the week (ie: first sunday of the month)
    # or we're on a valid day of the month (1, 15, -1)
    # Note: Rollover is not implemented, so the 35th day of the month is invalid.
    def in_interval?(date, start_date) 
      #make sure we're in the proper interval
      months_to_start_date = (date.month - start_date.month) + (date.year - start_date.year) * 12
      months_to_start_date % @interval == 0
    end
    
    def to_ical 
      'FREQ=MONTHLY' << to_ical_base
    end
    
    def to_s
      to_s_base 'month', 'months'
    end
    
    protected
    
    def default_jump(date)
      goal = date
      @interval.times do
        goal += TimeUtil.days_in_month(goal) * ONE_DAY
      end
      adjust(goal, date)
    end
 
    private

    def initialize(interval)
      super(interval)
    end
       
  end

end
