module IceCube

  class MinutelyRule < Rule

    # Determine whether this rule occurs on a give date.
    def occurs_on?(date, start_date)
      #make sure we're in a proper interval
      day_count = ((date - start_date) / ONE_MINUTE).to_i
      day_count % @interval == 0
    end

    def to_ical 
      'FREQ=MINUTELY' << to_ical_base
    end
        
    def to_s
      to_ical
    end
        
    protected
    
    def default_jump(date)
      date + ONE_MINUTE
    end

    private

    def initialize(interval)
      super(interval)
    end
        
  end

end
