module IceCube
  
  class Rule
    
    attr_reader :occurrence_count, :until_date
    
    include ValidationTypes

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
      hash[:validations].each do |validation, data|
        data.is_a?(Array) ? rule.send(validation, *data) : rule.send(validation, data)
      end
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
      @validation_types.values.all? do |validation|
        response = validation.send(:validate, date)
        response.nil? || response
      end
    end
    
    # The key - extremely educated guesses
    # This spidering behavior will go through look for the next suggestion
    # by constantly moving the farthest back value forward
    def next_suggestion(date)
      # get the next date recommendation set
      suggestions = {}; 
      @validation_types.each { |k, validation| suggestions[k] = validation.send(:closest, date) }
      compact_suggestions = suggestions.values.compact
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
          compact_suggestions = suggestions.values.compact
          min_suggestion = compact_suggestions.min
          # validate all against the minimum
          return min_suggestion if validate_single_date(min_suggestion)
          # move anything that is the minimum to its next closest
          @validation_types.each do |k, validation|
            suggestions[k] = validation.send(:closest, min_suggestion) if min_suggestion == suggestions[k]
          end
        end
      end
    end
    
    attr_reader :validations
    
    private
    
    def adjust(goal, date)
      return goal if goal.utc_offset == date.utc_offset
      goal - goal.utc_offset + date.utc_offset
    end
    
    # get a very meaningful string representation of this rule
    def to_s_base(singular, plural)
      representation = ''
      representation = 'Every ' << ((@interval == 1) ? singular : "#{@interval} #{plural}")
      @validation_types.values.each do |v|
        representation << ', ' << v.send(:to_s)
      end
      representation
    end
    
    #TODO - until date formatting is not iCalendar here
    #get the icalendar representation of this rule logic
    def to_ical_base
      representation = ''
      representation << ";INTERVAL=#{@interval}" if @interval > 1
      @validation_types.values.each do |v|
        representation << ';' << v.send(:to_ical)
      end      
      representation << ";COUNT=#{@occurrence_count}" if @occurrence_count
      representation << ";UNTIL=#{@until_date}" if @until_date
      representation
    end
    
    # Set the interval for the rule.  Depending on the type of rule,
    # interval means every (n) weeks, months, etc. starting on the start_date's
    def initialize(interval = 1)
      throw ArgumentError.new('Interval must be > 0') unless interval > 0
      @validations = {}
      @validation_types = {}
      @interval = interval
    end
    
  end

end
