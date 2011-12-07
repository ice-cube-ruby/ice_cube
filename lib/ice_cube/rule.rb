require 'yaml'

module IceCube

  class Rule

    attr_reader :uses

    # Expected to be overridden by subclasses
    def to_ical
      nil
    end

    # Yaml implementation
    def to_yaml(*args)
      to_hash.to_yaml(*args)
    end

    # Expected to be overridden by subclasses
    def to_hash
      nil
    end

    # From yaml
    def self.from_yaml(yaml)
      from_hash YAML::load(yaml)
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

    def on?(time, schedule)
      next_time(time, schedule) == time
    end

    # Compute the next time after (or including) the specified time in respect
    # to the given schedule
    def next_time(time, schedule)
      loop do
        break if @validations.all? do |name, vals|
          # Execute each validation
          res = vals.map do |validation|
            validation.validate(time, schedule)
          end
          # If there is any nil, then we're set - otherwise choose the lowest
          if res.any? { |r| r.nil? || r == 0 }
            true
          else
            return nil if res.all? { |r| r === true } # allow quick escaping
            res.reject! { |r| r.nil? || r == 0 || r === true }
            if fwd = res.min
              type = vals.first.type # get the jump type
              wrapper = TimeUtil::TimeWrapper.new(time)
              wrapper.add(type, fwd)
              wrapper.clear_below(type)
              # puts "fail - #{time} - #{name} - #{type} - #{res} - #{wrapper.to_time}"
              time = wrapper.to_time
            end
            false
          end
        end
      end
      # NOTE Uses may be 1 higher than proper here since end_time isn't validated
      # in this class.  This is okay now, since we never expose it - but if we ever
      # do - we should check that above this line, and return nil if end_time is past
      @uses += 1 if time
      time
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
