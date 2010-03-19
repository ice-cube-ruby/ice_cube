module IceCube

  class HourlyRule < Rule

    #TODO - optimization by checking interval before checking others

    # Determine whether this rule occurs on a give date.
    def occurs_on?(date, start_date)
      raise ArgumentError.new('Hourly rules must be used with DateTime') unless start_date.class == date.class && date.class == DateTime
      #determine whether the rule falls in our interval
      difference = DateTime.day_fraction_to_time(date - start_date)
      difference[0] = difference[0] % @interval
      return false unless difference == [0, 0, 0, 0]
      #validation
      return false unless validate(date, start_date)
    end

    def to_ical 
      'FREQ=HOURLY' << to_ical_base
    end
        
    def to_s
      to_ical
    end
        
  end

end