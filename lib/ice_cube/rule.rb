module IceCube
  
  class Rule
    
    attr_reader :occurrence_count, :until_date

    SuggestionTypes = [:month_of_year, :day_of_year, :day_of_month, :day_of_week, :day, :hour_of_day, :minute_of_hour, :second_of_minute]
    
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
    
    def self.hourly(interval = 1)
      HourlyRule.new(interval)
    end
    
    def self.minutely(interval = 1)
      MinutelyRule.new(interval)
    end
    
    def self.secondly(interval = 1)
      SecondlyRule.new(interval)
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

    def hour_of_day(*hours)
      @hours_of_day ||= []
      hours.each do |hour| 
        raise ArgumentError.new('Argument must be a valid hour') unless hour < 24 && hour >= 0
        @hours_of_day << hour
      end
      self
    end

    def minute_of_hour(*minutes)
      @minutes_of_hour ||= []
      minutes.each do |minute|
        raise ArgumentError.new('Argument must be a valid minute') unless minute < 60 && minute >= 0
        @minutes_of_hour << minute
      end
      self
    end
    
    # TODO - consider changing names to BY_ like in the RFC
    
    def second_of_minute(*seconds)
      @seconds_of_minute ||= []
      seconds.each do |second|
        raise ArgumentError.new('Argument must be a valid second') unless second < 60 && second >= 0
        @seconds_of_minute << second
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
    
    #TODO - move all of these into mixins
    
    def validate_single_date(date)
      SuggestionTypes.all? do |s|
        response = send("validate_#{s}", date)
        response.nil? || response
      end
    end
    
    # The key
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
    
    def self.from_yaml(str)
      YAML::load(str)
    end
    
  private
    
    #TODO utc to local
    #TODO look for some way not to duplicate code, or move into modules in sub-folder
    #TODO implement the rest of the RFC examples (time-based & set-pos)
    
    def validate_minute_of_hour(date)
      return true if !@minutes_of_hour || @minutes_of_hour.empty?
      @minutes_of_hour.include?(date.min)
    end
    
    def closest_minute_of_hour(date)
      return nil if !@minutes_of_hour || @minutes_of_hour.empty?
      # turn minutes into minutes of hour
      # minute >= 60 should fall into the next hour
      minutes = @minutes_of_hour.map do |m|
        m > date.min ? m - date.min : 60 - date.min + m
      end
      minutes.compact!
      # go to the closest distance away, the beginning of that minute
      closest_minute = minutes.min
      goal = date + closest_minute * 60
      Time.utc(goal.year, goal.month, goal.day, goal.hour, goal.min)
    end
    
    def validate_second_of_minute(date)
      return true if !@seconds_of_minute || @seconds_of_minute.empty?
      @seconds_of_minute.include?(date.sec)
    end
    
    def closest_second_of_minute(date)
      return nil if !@seconds_of_minute || @seconds_of_minute.empty?
      # turn seconds into seconds of minute
      # second >= 60 should fall into the next minute
      seconds = @seconds_of_minute.map do |s|
        s > date.sec ? s - date.sec : 60 - date.sec + s
      end
      seconds.compact!
      # go to the closest distance away
      closest_second = seconds.min
      date + closest_second
    end
    
    def validate_hour_of_day(date)
      return true if !@hours_of_day || @hours_of_day.empty?
      @hours_of_day.include?(date.hour)
    end
    
    def closest_hour_of_day(date)
      return nil if !@hours_of_day || @hours_of_day.empty?
      # turn hours into hour of day
      # hour >= 24 should fall into the next day
      hours = @hours_of_day.map do |h|
        h > date.hour ? h - date.hour : 24 - date.hour + h
      end
      hours.compact!
      # go to the closest distance away, the start of that hour
      closest_hour = hours.min
      goal = date + 60 * 60 * closest_hour
      Time.utc(goal.year, goal.month, goal.day, goal.hour)
    end
    
    def validate_day_of_week(date)
      # is it even one of the valid days?
      return true if !@days_of_week || @days_of_week.empty?
      return false unless @days_of_week.has_key?(date.wday) #shortcut
      # does this fall on one of the occurrences?
      first_occurrence = ((7 - Time.utc(date.year, date.month, 1).wday) + date.wday) % 7 + 1 #day of first occurrence of a wday in a month
      this_weekday_in_month_count = ((date.days_in_month - first_occurrence + 1) / 7.0).ceil #how many of these in the month
      nth_occurrence_of_weekday = (date.mday - first_occurrence) / 7 + 1 #what occurrence of the weekday is +date+
      @days_of_week[date.wday].include?(nth_occurrence_of_weekday) || @days_of_week[date.wday].include?(nth_occurrence_of_weekday - this_weekday_in_month_count - 1)
    end
    
    #note - temporary implementation
    def closest_day_of_week(date)
      return nil if !@days_of_week || @days_of_week.empty?
      tdate = date.dup
      while tdate += ONE_DAY
        return tdate if validate_day_of_week(tdate)
      end
    end
    
    def validate_month_of_year(date)
      return true if !@months_of_year || @months_of_year.empty?
      @months_of_year.include?(date.month)
    end
    
    def closest_month_of_year(date)
      return nil if !@months_of_year || @months_of_year.empty?
      # turn months into month of year
      # month > 12 should fall into the next year
      months = @months_of_year.map do |m|
        m > date.month ? m : m + 12
      end
      months.compact!
      # go to the closest distance away
      closest_month = months.min
      closest_month < 12 ? Time.utc(date.year, closest_month, date.day) : Time.utc(date.year + 1, closest_month - 12, date.day)
    end
    
    def validate_day_of_month(date)
      return true if !@days_of_month || @days_of_month.empty?
      @days_of_month.include?(date.mday) || @days_of_month.include?(date.mday - date.days_in_month - 1)
    end
    
    def closest_day_of_month(date)
      return nil if !@days_of_month || @days_of_month.empty?
      #get some variables we need
      days_in_month = date.days_in_month
      days_left_in_this_month = days_in_month - date.mday
      next_month, next_year = date.month == 12 ? [1, date.year + 1] : [date.month + 1, date.year] #clean way to wrap over years
      days_in_next_month = Time.utc(next_year, next_month, 1).days_in_month
      # create a list of distances
      distances = []
      @days_of_month.each do |d|
        if d > 0
          distances << d - date.mday #today is 1, we want 20 (19)
          distances << days_left_in_this_month + d #(364 + 20)
        elsif d < 0
          distances << (days_in_month + d + 1) - date.mday #today is 30, we want -1
          distances << (days_in_next_month + d + 1) + days_left_in_this_month #today is 300, we want -70
        end
      end
      #return the lowest distance
      distances = distances.select { |d| d > 0 }
      return nil if distances.empty?
      # return the start of the proper day
      goal = date + distances.min * ONE_DAY
      Time.utc(goal.year, goal.month, goal.day)
    end
      
    def validate_day_of_year(date)
      return true if !@days_of_year || @days_of_year.empty?
      @days_of_year.include?(date.yday) || @days_of_year.include?(date.yday - date.days_in_year - 1)
    end
    
    def closest_day_of_year(date)
      return nil if !@days_of_year || @days_of_year.empty?
      #get some variables we need
      days_in_year = date.days_in_year
      days_left_in_this_year = days_in_year - date.yday
      days_in_next_year = Time.utc(date.year + 1, 1, 1).days_in_year
      # create a list of distances
      distances = []
      @days_of_year.each do |d|
        if d > 0
          distances << d - date.yday #today is 1, we want 20 (19)
          distances << days_left_in_this_year + d #(364 + 20)
        elsif d < 0
          distances << (days_in_year + d + 1) - date.yday #today is 300, we want -1
          distances << (days_in_next_year + d + 1) + days_left_in_this_year #today is 300, we want -70
        end
      end
      #return the lowest distance
      #TODO - use inject in here and day_of_month
      distances = distances.select { |d| d > 0 }
      return nil if distances.empty?
      # return the start of the proper day
      goal = date + distances.min * ONE_DAY
      Time.utc(goal.year, goal.month, goal.day)
    end

    def validate_day(date)
      return true if !@days || @days.empty?
      @days.include?(date.wday)
    end
    
    def closest_day(date)
      return nil if !@days || @days.empty?
      # turn days into distances
      days = @days.map do |d| 
        d > date.wday ? (d - date.wday) : (7 - date.wday + d)
      end
      days.compact!
      # go to the closest distance away, the start of that day
      goal = date + days.min * ONE_DAY
      Time.utc(goal.year, goal.month, goal.day)
    end
    
    #TODO - add new time rules into to_ical_base
    
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
      representation << ';BYHOUR=' << @hours_of_day.join(',') if @hours_of_day
      representation << ';BYMINUTE=' << @minutes_of_hour.join(',') if @minutes_of_hour
      representation << ';BYSECOND=' << @seconds_of_minute.join(',') if @seconds_of_minute
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
