module IceCube

  class DailyRule < Rule

    # Determine whether this rule occurs on a give date.
    def in_interval?(date, start_date)
      #make sure we're in a proper interval
      day_count = ((date - start_date) / ONE_DAY).to_i
      day_count % @interval == 0
    end

    def to_ical 
      'FREQ=DAILY' << to_ical_base
    end
        
    protected
    
    def default_jump(date)
      date + ONE_DAY * @interval
    end
     
    private
    
    def initialize(interval)
      super(interval)
    end
        
  end

end
