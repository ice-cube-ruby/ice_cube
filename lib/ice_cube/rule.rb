module IceCube
  
  class Rule
    
    attr_reader :occurrence_count, :until_date
    attr_reader :interval
    attr_reader :validations
    
    include ValidationTypes
    include Comparable

    # Compare based on hash representations
    def <=>(other)
      to_hash <=> other.to_hash
    end

    def to_hash
      hash = Hash.new
      hash[:rule_type] = self.class.name
      hash[:interval] = @interval
      hash[:until] = @until_date ? TimeUtil.serialize_time(@until_date) : @until_date
      hash[:count] = @occurrence_count
      hash[:validations] = @validations
      hash
    end
    
    def self.from_hash(hash)
      rule = hash[:rule_type].split('::').inject(Object) { |namespace, const_name| namespace.const_get(const_name) }.new(hash[:interval])
      rule.count(hash[:count]) if hash[:count]
      rule.until(TimeUtil.deserialize_time(hash[:until])) if hash[:until]
      hash[:validations].each do |validation, data|
        data.is_a?(Array) ? rule.send(validation, *data) : rule.send(validation, data)
      end
      rule
    end
        
    def to_yaml(options = {})
      to_hash.to_yaml(options)
    end

    def self.from_yaml(str)
      from_hash(YAML::load(str))
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
    
    # The key to speed - extremely educated guesses
    # This spidering behavior will go through look for the next suggestion
    # by constantly moving the farthest back value forward
    def next_suggestion(date)
      # get the next date recommendation set
      suggestions = {}; 
      @validation_types.each { |k, validation| suggestions[k] = validation.send(:closest, date) }
      compact_suggestions = suggestions.values.compact
      # find the next date to go to
      if compact_suggestions.empty?
        attempt_count = 0
        loop do
          # keep going through rule suggestions
          next_date = self.default_jump(date, attempt_count += 1)
          return next_date if !next_date.nil? && validate_single_date(next_date)
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
      representation = (@interval == 1 ? singular : plural)
      representation << @validation_types.values.map { |v| ' ' + v.send(:to_s) }.join()
      representation << " #{occurrence_count} #{@occurrence_count == 1 ? 'time' : 'times'}" if @occurrence_count
      representation
    end
    
    # get the icalendar representation of this rule logic
    # Note: UNTIL dates are always in UTC as per iCalendar
    def to_ical_base
      representation = ''
      representation << ";INTERVAL=#{@interval}" if @interval > 1
      @validation_types.values.each do |v|
        representation << ';' << v.send(:to_ical)
      end      
      representation << ";COUNT=#{@occurrence_count}" if @occurrence_count
      representation << ";UNTIL=#{TimeUtil.ical_utc_format(@until_date)}" if @until_date
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
