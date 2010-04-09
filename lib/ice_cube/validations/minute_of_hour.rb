module IceCube

  class MinuteOfHourValidation < Validation
  
    def initialize(rule)
      @minutes_of_hour = rule.validations[:minute_of_hour]
    end
  
    def validate(date)
      return true if !@minutes_of_hour || @minutes_of_hour.empty?
      @minutes_of_hour.include?(date.min)
    end
  
    def closest(date)
      return nil if !@minutes_of_hour || @minutes_of_hour.empty?
      # turn minutes into minutes of hour
      # minute >= 60 should fall into the next hour
      minutes = @minutes_of_hour.map do |m|
        m > date.min ? m - date.min : 60 - date.min + m
      end
      minutes.compact!
      # go to the closest distance away, the beginning of that minute
      closest_minute = minutes.min
      goal = date + closest_minute * IceCube::ONE_MINUTE
      adjust(goal, date)
    end
    
    def to_s
      'on the ' << nice_numbers(@minutes_of_hour) << (@minutes_of_hour.count == 1 ? ' minute' : ' minutes') << ' of the hour' unless @minutes_of_hour.empty?
    end

    def to_ical
      'BYMINUTE=' << @minutes_of_hour.join(',') unless @minutes_of_hour.empty?
    end
    
  end
  
end