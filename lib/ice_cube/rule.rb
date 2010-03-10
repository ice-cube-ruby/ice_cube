module IceCube
  
  class Rule

    # create a new daily rule
    def self.daily(interval = 1)
      DailyRule.new(interval)
    end

    # create a new weekly rule
    def self.weekly(interval = 1)
      WeeklyRule.new(interval)
    end

    # create a new monthly rule
    def self.monthly(interval = 1)
      MonthlyRule.new(interval)
    end

    # create a new yearly rule
    def self.yearly(interval = 1)
      YearlyRule.new(interval)
    end

    # Set the time when this rule will no longer be effective
    def until(until_date)
      raise ArgumentError.new('Argument must be a valid date') unless until_date.class == Date
      @until_date = until_date
      self
    end
      
  private
    # Set the interval for the rule.  Depending on the type of rule,
    # interval means every (n) weeks, months, etc. starting on the start_date's
    def initialize(interval)
      throw ArgumentError.new('Interval must be > 0') unless interval > 0
      @interval = interval
    end
    
    # perform some basic validation
    def validate(date, start_date)
      return false if @until_date && (date > @until_date)
      return false if date < start_date
      true
    end
    
  end

end
