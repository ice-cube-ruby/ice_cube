module IceCube

  class MonthlyRule < WeeklyRule

    # Determine for a given date/start_date if this rule occurs or not.
    # Month rules occur if we're in a valid interval
    # and either (1) we're on a valid day of the week (ie: first sunday of the month)
    # or we're on a valid day of the month (1, 15, -1)
    # Note: Rollover is not implemented, so the 35th day of the month is invalid.
    def occurs_on?(date, start_date) 
      # if we haven't performed any other validations, perform the default validation
      # which is to make sure that the day falls on the same day of the month as the start_date
      unless has_obscure_validations?
        return false unless date.mday == start_date.mday #as per RFC, dates are skipped
      end
      #make sure we're in the proper interval
      months_to_start_date = (date.month - start_date.month) + (date.year - start_date.year) * 12
      return false unless months_to_start_date % @interval == 0
      #validation
      validate(date, start_date)
    end
    
    def to_ical 
      'FREQ=MONTHLY' << to_ical_base
    end
    
    def to_s
      to_ical
    end
    
  end

end
