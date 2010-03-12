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
      raise ArgumentError.new('Cannot specify until and count on the same rule') if @count #as per rfc
      raise ArgumentError.new('Argument must be a valid date') unless until_date.class == Date
      @until_date = until_date
      self
    end

    # Specify what months of the year this rule applies to.  
    # ie: Schedule.yearly(2).month_of_year(:january, :march) would create a
    # rule which occurs every january and march, every other year
    # Note: you cannot combine day_of_year and month_of_year in the same rule.
    def month_of_year(*months)
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
    
    # set the number of occurrences after which this rule is no longer effective
    def count(count)
      raise ArgumentError.new('Argument must be a positive integer') unless Integer(count) && count > 0 #todo - maybe allow count to be 0
      @count = count
      self
    end
    
    attr_reader :count
    
  private
    
    #get the icalendar representation of this rule logic
    def to_ical_base
      representation = ''
      representation << ";INTERVAL=#{@interval}" if @interval > 1
      representation << ';BYMONTH=' << @months_of_year.join(',') if @months_of_year
      representation << ';BYYEARDAY=' << @days_of_year.join(',') if @days_of_year
      representation << ';BYMONTHDAY=' << @days_of_month.join(',') if @days_of_month
      if @days || @days_of_week
        representation << ';BYDAY='
        days_of_week_dedup = @days_of_week.dup if @days_of_week
        #put days on the string, remove all occurrences in days from days_of_week
        if @days
          @days.each { |day| days_of_week_dedup.delete(day) } if days_of_week_dedup
          representation << (@days.map { |d| ICAL_DAYS[d]} ).join(',')
        end 
        representation << ',' if @days && @days_of_week
        #put days_of_week on string representation
        representation << days_of_week_dedup.inject([]) do |day_rules, pair|
          day, occ = *pair
          day_rules.concat(occ.map {|v| v.to_s + ICAL_DAYS[day]})
        end.flatten.join(',') if days_of_week_dedup
      end
      representation << ";COUNT=#{@count}" if @count
      representation << ";UNTIL=#{@until}" if @until_date
      representation
    end
    
    # Set the interval for the rule.  Depending on the type of rule,
    # interval means every (n) weeks, months, etc. starting on the start_date's
    def initialize(interval = 1)
      throw ArgumentError.new('Interval must be > 0') unless interval > 0
      @interval = interval
    end
    
    def validate(date, start_date)
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
