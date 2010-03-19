module IceCube

  class DailyRule < Rule

    # Determine whether this rule occurs on a give date.
    def occurs_on?(date, start_date)
      #make sure we're in a proper interval
      day_count = (start_date...date).count
      return false unless day_count % @interval == 0
      #perform validations
      validate(date, start_date)
    end

    def to_ical 
      'FREQ=DAILY' << to_ical_base
    end
        
    def to_s
      to_ical
    end
        
    def start_of_next_interval(date)
      date + @interval
    end
        
  end

end
