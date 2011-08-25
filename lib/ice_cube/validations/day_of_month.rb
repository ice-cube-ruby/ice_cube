module IceCube

  class DayOfMonthValidation < Validation

    attr_reader :days_of_month
    
    def initialize(rule)
      @days_of_month = rule.validations[:day_of_month]
    end
    
    def validate(date)
      return true if !@days_of_month || @days_of_month.empty?
      @days_of_month.include?(date.mday) || @days_of_month.include?(date.mday - TimeUtil.days_in_month(date) - 1)
    end
  
    def closest(date)
      return nil if !@days_of_month || @days_of_month.empty?
      #get some variables we need
      days_in_month = TimeUtil.days_in_month(date)
      days_left_in_this_month = days_in_month - date.mday
      next_month, next_year = date.month == 12 ? [1, date.year + 1] : [date.month + 1, date.year] #clean way to wrap over years
      days_in_next_month = TimeUtil.days_in_month(Time.utc(next_year, next_month, 1))
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
      goal = date + distances.min * IceCube::ONE_DAY
      self.class.adjust(goal, date)
    end
    
    def to_s
      'on the ' << self.class.nice_numbers(@days_of_month) << (@days_of_month.size == 1 ? ' day' : ' days') << ' of the month' unless @days_of_month.empty?
    end
  
    def to_ical
      'BYMONTHDAY=' << @days_of_month.join(',') unless @days_of_month.empty?
    end
    
  end
  
end
