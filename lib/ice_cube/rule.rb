module IceCube
  
  class Rule
    
    attr_reader :occurrence_count, :until_date

    SuggestionTypes = []
    include MonthOfYearValidation, DayOfYearValidation, DayOfMonthValidation, DayOfWeekValidation, DayValidation
    include HourOfDayValidation, MinuteOfHourValidation, SecondOfMinuteValidation
    
    def to_hash
      hash = Hash.new
      hash[:rule_type] = self.class.name
      hash[:interval] = @interval
      hash[:until] = @until_date
      hash[:count] = @occurrence_count
      hash[:validations] = @validations
      hash
    end
    
    def self.from_hash(hash)
      rule = hash[:rule_type].split('::').inject(Object) { |namespace, const_name| namespace.const_get(const_name) }.new(hash[:interval])
      rule.count(hash[:count]) if hash[:count]
      rule.until(hash[:until]) if hash[:until]
      rule.validations = hash[:validations]
      rule
    end
    
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
    
    # create a new hourly rule
    def self.hourly(interval = 1)
      HourlyRule.new(interval)
    end
    
    # create a new minutely rule
    def self.minutely(interval = 1)
      MinutelyRule.new(interval)
    end
    
    # create a new secondly rule
    def self.secondly(interval = 1)
      SecondlyRule.new(interval)
    end
    
    # Set the time when this rule will no longer be effective
    def until(until_date)
      raise ArgumentError.new('Cannot specify until and count on the same rule') if @count #as per rfc
      @until_date = until_date
      self
    end
    
    # set the number of occurrences after which this rule is no longer effective
    def count(count)
      raise ArgumentError.new('Argument must be a positive integer') unless Integer(count) && count >= 0
      @occurrence_count = count
      self
    end
    
    def validate_single_date(date)
      SuggestionTypes.all? do |s|
        response = send("validate_#{s}", date)
        response.nil? || response
      end
    end
    
    # The key - extremely educated guesses
    # This spidering behavior will go through look for the next suggestion
    # by constantly moving the farthest back value forward
    def next_suggestion(date)
      # get the next date recommendation set
      suggestions = SuggestionTypes.map { |r| send("closest_#{r}", date) }
      compact_suggestions = suggestions.compact
      # find the next date to go to
      if compact_suggestions.empty?
        next_date = date
        loop do
          # keep going through rule suggestions
          next_date = self.default_jump(next_date)
          return next_date if validate_single_date(next_date)
        end
      else  
        loop do
          compact_suggestions = suggestions.compact
          min_suggestion = compact_suggestions.min
          # validate all against the minimum
          return min_suggestion if validate_single_date(min_suggestion)
          # move anything that is the minimum to its next closest
          SuggestionTypes.each_with_index do |r, index|
            suggestions[index] = send("closest_#{r}", min_suggestion) if min_suggestion == suggestions[index]
          end
        end
      end
    end
    
    def to_s
      to_ical
    end
    
    attr_accessor :validations
    
    private
    
    def adjust(goal, date)
      return goal if goal.utc_offset == date.utc_offset
      goal - goal.utc_offset + date.utc_offset
    end
    
    #TODO - until date formatting is not iCalendar here
    #get the icalendar representation of this rule logic
    def to_ical_base
      representation = ''
      representation << ";INTERVAL=#{@interval}" if @interval > 1
      representation << ';BYMONTH=' << @validations[:month_of_year].join(',') if @validations[:month_of_year]
      representation << ';BYYEARDAY=' << @validations[:day_of_year].join(',') if @validations[:day_of_year]
      representation << ';BYMONTHDAY=' << @validations[:day_of_month].join(',') if @validations[:day_of_month]
      if @validations[:day] || @validations[:day_of_week]
        representation << ';BYDAY='
        days_dedup = @validations[:day].dup if @validations[:day]
        #put days on the string, remove all occurrences in days from days_of_week
        if days_dedup
          @validations[:day_of_week].keys.each { |day| days_dedup.delete(day) } if @validations[:day_of_week]
          representation << (days_dedup.map { |d| IceCube::ICAL_DAYS[d]} ).join(',')
        end 
        representation << ',' if days_dedup && @validations[:day_of_week]
        #put days_of_week on string representation
        representation << @validations[:day_of_week].inject([]) do |day_rules, pair|
          day, occ = *pair
          day_rules.concat(occ.map {|v| v.to_s + IceCube::ICAL_DAYS[day]})
        end.flatten.join(',') if @validations[:day_of_week]
      end
      representation << ';BYHOUR=' << @validations[:hour_of_day].join(',') if @validations[:hour_of_day]
      representation << ';BYMINUTE=' << @validations[:minute_of_hour].join(',') if @validations[:minute_of_hour]
      representation << ';BYSECOND=' << @validations[:second_of_minute].join(',') if @validations[:second_of_minute]
      representation << ";COUNT=#{@occurrence_count}" if @occurrence_count
      representation << ";UNTIL=#{@until_date}" if @until_date
      representation
    end
    
    # Set the interval for the rule.  Depending on the type of rule,
    # interval means every (n) weeks, months, etc. starting on the start_date's
    def initialize(interval = 1)
      throw ArgumentError.new('Interval must be > 0') unless interval > 0
      @validations = {}
      @interval = interval
    end
    
  end

end
