module IceCube

  class HourlyRule < Rule

    #TODO - optimization by checking interval before checking others

    # Determine whether this rule occurs on a give date.
    def occurs_on?(date, start_date)
      raise ArgumentError.new('Hourly rules must be used with DateTime') unless start_date.class == date.class && date.class == DateTime
      return false unless validate(date, start_date)
      #determine whether the rule falls in our interval
      difference = Date.day_fraction_to_time(date - start_date)
      difference[0] = difference[0] % @interval
      difference == [0, 0, 0, 0]
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