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
      raise ArgumentError.new('Argument must be a valid Time') unless until_date.class == Time
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
      @occurrence_count = count
      self
    end
    
    #TODO - move nil checking into functions to clean this up to just an array
    #TODO - collapse mass assignments
    #TODO - centralize suggestion_types
    
    def validate_single_date(date)
      suggestion_types = [:day, :month_of_year]
      suggestion_types.all? do |s| 
        response = send("validate_#{s}", date)
        response.nil? || response
      end
    end
    
    #TODO - move to RFC order in suggestion types
    
    # MY MASTERPIECE
    def next_suggestion(date)
      suggestion_types = [:day, :month_of_year]
      #get initial suggestions
      suggestions = suggestion_types.map { |s| send("closest_#{s}", date) }
      #CRAZY SPIDERS - @TODO - document
      loop do
        #if all of the suggestions are the same (or nil), we've found a viable date... otherwise keeping pushing the back one forward
        compact_suggestions = suggestions.compact
        return self.class.default_jump(date) if compact_suggestions.empty?
        return compact_suggestions.first if compact_suggestions.all? { |s| s == compact_suggestions.first }
        # find the index of the maximum suggestion (may be multiple)
        max_suggestion = compact_suggestions.max #don't recompute
        to_recall = compact_suggestions.select { |s| s != max_suggestion }
        # recall and reindex the suggestion
        to_recall.each { |i| suggestions[i] = send("closest_#{suggestion_types[i]}", max_suggestion) }
      end
    end
    
    def self.from_yaml(str)
      YAML::load(str)
    end
    
    attr_reader :occurrence_count, :until_date
    
  private
    
    #TODO utc to local
    
    def validate_month_of_year(date)
      !@months_of_year || @months_of_year.include?(date.month)
    end
    
    def closest_month_of_year(date)
      return nil if !@days_of_month || @days_of_month.empty?
      # turn months into month of year
      # month > 12 should fall into the next year
      months = @months_of_year.map do |m|
        m if m > date.month
        m + 12 if m <= date.month
      end.compact!
      return nil if months.empty?
      # go to the closest distance away
      closest_month = months.min
      closest_month < 12 ? Time.utc(date.year, closest_month, date.day) : Time.utc(date.year + 1, closest_month - 12, date.day)
    end

    def validate_day(date)
      !@days || @days.include?(date.wday)
    end
    
    def closest_day(date)
      return nil if !@days || @days.empty?
      # turn days into distances
      days = @days.map do |d| 
        if d > date.wday : d - date.wday
        elsif d < date.wday : 7 - date.wday - d
        end
      end
      days.compact!
      return nil if days.empty?
      # go to the closest distance away, the start of that day
      goal = date + days.min * ONE_DAY
      Time.utc(goal.year, goal.month, goal.day)
    end
    
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
  
    def has_obscure_validations?
      !!(@months_of_year || @days_of_year || @days || @days_of_week || @days_of_month)
    end
    
  end

end
