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

    # Set the count
    def count(count)
      @count = count
      self
    end

    # Specify what months of the year this rule applies to.  
    # ie: Schedule.yearly(2).month_of_year(:january, :march) would create a
    # rule which occurs every january and march, every other year
    # Note: you cannot combine day_of_year and month_of_year in the same rule.
    def month_of_year(*months)
      raise ArgumentError.new('Cannot specify month_of_year AND day_of_year') if @days_of_year
      @months_of_year ||= []
      months.each do |month|
        raise ArgumentError.new('Argument must be a valid month') unless MONTHS.has_key?(month)
        @months_of_year << MONTHS[month]
      end
      self
    end

    # Specify what days of the year this rule applies to.
    # ie: Schedule.yearly(2).days_of_year(17, -1) would create a
    # rule which occurs every 17th and last day of every other year.
    # Note: you cannot combine month_of_year and day_of_year in the same rule.
    def day_of_year(*days)
      raise ArgumentError.new('Cannot specify month_of_year AND day_of_year') if @months_of_year
      @days_of_year ||= []
      days.each do |day|
        raise ArgumentError.new('Argument must be a valid day') if day.abs > 366
        raise ArgumentError.new('Argument must be non-zero') if day == 0
        @days_of_year << day
      end
      self
    end

    # Specify the days of the month that this rule should
    # occur on.  ie: rule.day_of_month(1, -1) would mean that
    # this rule should occur on the first and last day of every month.
    def day_of_month(*days)
      @days_of_month ||= []
      days.each do |day|
        raise ArgumentError.new('Argument must be a valid date') if day.abs > 31 
        raise ArgumentError.new('Argument must be non-zero') if day == 0
        @days_of_month << day
      end
      self
    end

    # Specify the day(s) of the week that this rule should occur
    # on.  ie: rule.day_of_week(:monday => [1, -1]) would mean
    # that this rule should occur on the first and last mondays of each month.
    def day_of_week(days)
      @days_of_week ||= {}
      days.each do |day, occurrences|
        raise ArgumentError.new('Argument must be a valid day') unless DAYS.has_key?(day)
        @days_of_week[DAYS[day]] ||= []
        @days_of_week[DAYS[day]] += occurrences #TODO - change to concat
      end
      self
    end

    # Specify what days of the week this rule should occur on.
    # ie: Schedule.weekly.day_of_week(:monday) would create a rule that
    # occurs every monday.
    def day(*days)
      @days ||= []
      days.each do |day|
        raise ArgumentError.new('Argument must be a valid day of the week') unless DAYS.has_key?(day)
        @days << DAYS[day]
      end
      self
    end
    
    attr_accessor :occurrence_count
    
  private

    # Set the interval for the rule.  Depending on the type of rule,
    # interval means every (n) weeks, months, etc. starting on the start_date's
    def initialize(interval)
      throw ArgumentError.new('Interval must be > 0') unless interval > 0
      @interval = interval
      @occurrence_count = 0
    end
    
    def validate(date, start_date)
      return false if @count && @occurrence_count >= @count # break rfc evaluation order for speed increase
      return false if @until_date && (date > @until_date)
      return false if date < start_date
      # execute validations in RFC 2445 order
      return false unless validate_months_of_year(date)
      return false unless validate_days_of_year(date)
      return false unless validate_days_of_month(date)
      return false unless validate_days_of_week(date)
      return false unless validate_days(date)
      true
    end

    def has_obscure_validations?
      @months_of_year || @days_of_year || @days || @days_of_week || @days_of_month
    end

    def validate_months_of_year(date)
      return true unless @months_of_year
      @months_of_year.include?(date.month)
    end
    
    def validate_days_of_year(date)
      return true unless @days_of_year
      days_in_year = Date.civil(date.year, 12, -1).yday
      @days_of_year.include?(date.yday) || @days_of_year.include?(date.yday - days_in_year - 1)
    end

    def validate_days_of_month(date)
      return true unless @days_of_month
      number_of_days_in_month = Date.civil(date.year, date.month, -1).day
      @days_of_month.include?(date.mday - number_of_days_in_month - 1) || @days_of_month.include?(date.mday)
    end

    def validate_days_of_week(date)
      return true unless @days_of_week
      return false unless @days_of_week.has_key?(date.wday)
      number_of_days_in_month = Date.civil(date.year, date.month, -1).day
      first_occurrence = ((7 - Date.civil(date.year, date.month, 1).wday) + date.wday) % 7 + 1 #day of first occurrence of a wday in a month
      this_weekday_in_month_count = ((number_of_days_in_month - first_occurrence + 1) / 7.0).ceil #how many of these in the month
      nth_occurrence_of_weekday = (date.mday - first_occurrence) / 7 + 1 #what occurrence of the weekday is +date+
      @days_of_week[date.wday].include?(nth_occurrence_of_weekday) || @days_of_week[date.wday].include?(nth_occurrence_of_weekday - this_weekday_in_month_count - 1)
    end

    def validate_days(date)
      return true unless @days
      @days.include?(date.wday)
    end
    
  end

end
