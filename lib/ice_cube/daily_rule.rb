module IceCube

  class DailyRule < Rule

    # Determine whether this rule occurs on a give date.
    def occurs_on?(date, start_date)
      return false unless validate(date, start_date)
      #determine whether the rule falls in our interval
      day_count = (start_date...date).count
      day_count % @interval == 0
    end

    # A meaningful string representation of this rule
    def to_s
      "Every #{@interval} day(s)"
    end
      
  end

end
