module IceCube

  class DayValidation < Validation

    attr_reader :days
  
    def initialize(rule)
      @days = rule.validations[:day]
      @rule = rule
    end
  
    def validate(date)
      return true if !@days || @days.empty?
      @days.include?(date.wday)
    end
  
    def closest(date)
      return nil if !@days || @days.empty?
      # turn days into distances
      days = @days.map do |d| 
        d > date.wday ? (d - date.wday) : (7 - date.wday + d)
      end
      days.compact!
      # go to the closest distance away, the start of that day
      goal = date + days.min * IceCube::ONE_DAY
      self.class.adjust(goal, date)
    end
  
    def to_s
      days_dup = (@days - @rule.validations[:day_of_week].keys if @rule.validations[:day_of_week]) || @days # don't list twice
      if days_dup.sort == [1,2,3,4,5]
        'on all Weekdays'
      elsif days_dup.present?
        'on ' << self.class.sentence(days_dup.map { |d| Date::DAYNAMES[d] + 's' })
      end
    end

    def to_ical
      days_dup = (@days - @rule.validations[:day_of_week].keys if @rule.validations[:day_of_week]) || @days # don't list twice
      'BYDAY=' << days_dup.map { |d| IceCube::ICAL_DAYS[d] }.join(',') unless days_dup.empty?
    end
  
  end

end
