module IceCube

  class SecondOfMinuteValidation < Validation
  
    def initialize(rule)
      @seconds_of_minute = rule.validations[:second_of_minute]
    end
  
    def validate(date)
      return true if !@seconds_of_minute || @seconds_of_minute.empty?
      @seconds_of_minute.include?(date.sec)
    end
  
    def closest(date)
      return nil if !@seconds_of_minute || @seconds_of_minute.empty?
      # turn seconds into seconds of minute
      # second >= 60 should fall into the next minute
      seconds = @seconds_of_minute.map do |s|
        s > date.sec ? s - date.sec : 60 - date.sec + s
      end
      seconds.compact!
      # go to the closest distance away
      closest_second = seconds.min
      goal = date + closest_second
      self.class.adjust(goal, date)
    end

    def to_s
      'on the ' << self.class.nice_numbers(@seconds_of_minute) << (@seconds_of_minute.size == 1 ? ' second' : ' seconds') << ' of the minute' unless @seconds_of_minute.empty?
    end

    def to_ical
      'BYSECOND=' << @seconds_of_minute.join(',') unless @seconds_of_minute.empty?
    end
  
  end
  
end
