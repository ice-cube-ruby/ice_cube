require 'yaml'

module IceCube

  class Rule

    attr_reader :uses

    # Is this a terminating schedule?
    def terminating?
      until_time || occurrence_count
    end

    def ==(rule)
      if rule.is_a? Rule
        hash = to_hash
        hash && hash == rule.to_hash
      end
    end

    def hash
      h = to_hash
      h.nil? ? super : h.hash
    end

    # Expected to be overridden by subclasses
    def to_ical
      nil
    end
    
    def self.from_ical ical
      params = {:validations => {}}
      
      ical.split(';').each do |rule|
        (name, value) = rule.split('=')
        case name
        when 'FREQ'
          params[:freq] = value.downcase
        when 'INTERVAL'
          params[:interval] = value.to_i
        when 'COUNT'
          params[:count] = value.to_i
        when 'UNTIL'
          params[:until] = DateTime.parse(value).to_time.utc
          
        when 'BYSECOND'
          params[:validations][:second_of_minute] = value.split(',').collect{ |v| v.to_i }
        when "BYMINUTE"
          params[:validations][:minute_of_hour] = value.split(',').collect{ |v| v.to_i }
        when "BYHOUR"
          params[:validations][:hour_of_day] = value.split(',').collect{ |v| v.to_i }
        when "BYDAY"
          dows = {}
          days = []
          value.split(',').each do |expr|
              day = TimeUtil.ical_day_to_symbol(expr.strip[-2..-1])
              if expr.strip.length > 2  # day with occurence
                occ = expr[0..-3].to_i 
                dows[day].nil? ? dows[day] = [occ] : dows[day].push(occ)
                days.delete(TimeUtil.symbol_to_day(day))
              else
                days.push TimeUtil.symbol_to_day(day) if dows[day].nil?
              end
          end
          params[:validations][:day_of_week] = dows unless dows.empty?
          params[:validations][:day] = days unless days.empty?
        when "BYMONTHDAY"
          params[:validations][:day_of_month] = value.split(',').collect{ |v| v.to_i }
        when "BYMONTH"
          params[:validations][:month_of_year] = value.split(',').collect{ |v| v.to_i }
        when "BYYEARDAY"
          params[:validations][:day_of_year] = value.split(',').collect{ |v| v.to_i }
          
        else
          raise "Invalid or unsupported rrule command : #{name}"
        end
      end
      
      rule = IceCube::Rule.send(params[:freq], params[:interval] || 1)
      rule.count(params[:count]) if params[:count]
      rule.until(params[:until]) if params[:until]
      params[:validations].each do |key, value|
        value.is_a?(Array) ? rule.send(key, *value) : rule.send(key, value)
      end

      rule
    end

    # Yaml implementation
    def to_yaml(*args)
      defined?(Psych) ? Psych::dump(to_hash) : YAML::dump(to_hash, *args)
    end

    # From yaml
    def self.from_yaml(yaml)
      from_hash defined?(Psych) ? Psych::load(yaml) : YAML::load(yaml)
    end

    # Expected to be overridden by subclasses
    def to_hash
      nil
    end

    # Convert from a hash and create a rule
    def self.from_hash(hash)
      return nil unless match = hash[:rule_type].match(/\:\:(.+?)Rule/)
      rule = IceCube::Rule.send(match[1].downcase.to_sym, hash[:interval] || 1)
      rule.until(TimeUtil.deserialize_time(hash[:until])) if hash[:until]
      rule.count(hash[:count]) if hash[:count]
      hash[:validations] && hash[:validations].each do |key, value|
        key = key.to_sym unless key.is_a?(Symbol)
        value.is_a?(Array) ? rule.send(key, *value) : rule.send(key, value)
      end
      rule
    end

    # Reset the uses on the rule to 0
    def reset
      @uses = 0
    end

    def next_time(time, schedule, closing_time)
    end

    def on?(time, schedule)
      next_time(time, schedule, time) == time
    end

    # Convenience methods for creating Rules
    class << self

      # Secondly Rule
      def secondly(interval = 1)
        SecondlyRule.new(interval)
      end

      # Minutely Rule
      def minutely(interval = 1)
        MinutelyRule.new(interval)
      end

      # Hourly Rule
      def hourly(interval = 1)
        HourlyRule.new(interval)
      end

      # Daily Rule
      def daily(interval = 1)
        DailyRule.new(interval)
      end

      # Weekly Rule
      def weekly(interval = 1)
        WeeklyRule.new(interval)
      end

      # Monthly Rule
      def monthly(interval = 1)
        MonthlyRule.new(interval)
      end

      # Yearly Rule
      def yearly(interval = 1)
        YearlyRule.new(interval)
      end

    end
    
  end

end
