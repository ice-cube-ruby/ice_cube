module IceCube

  class HourOfDayValidation < Validation
  
    def initialize(rule)
      @hours_of_day = rule.validations[:hour_of_day]
    end
  
    def validate(date)
      return true if !@hours_of_day || @hours_of_day.empty?
      @hours_of_day.include?(date.hour)
    end
  
    def closest(date)
      return nil if !@hours_of_day || @hours_of_day.empty?
      # turn hours into hour of day
      # hour >= 24 should fall into the next day
      hours = @hours_of_day.map do |h|
        h > date.hour ? h - date.hour : 24 - date.hour + h
      end
      hours.compact!
      # go to the closest distance away, the start of that hour
      closest_hour = hours.min
      goal = date + IceCube::ONE_HOUR * closest_hour
      adjust(goal, date)
    end

    def to_s
      'on the ' << nice_numbers(@hours_of_day.sort) << (@hours_of_day.count == 1 ? ' hour' : ' hours') << ' of the day' unless @hours_of_day.empty?
    end

    def to_ical
      'BYHOUR=' << @hours_of_day.join(',') unless @hours_of_day.empty?
    end
  
  end
  
end