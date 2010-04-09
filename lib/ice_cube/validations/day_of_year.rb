module IceCube
  
  class DayOfYearValidation < Validation
    
    def initialize(rule)
      @days_of_year = rule.validations[:day_of_year]
    end
  
    def validate(date)
      return true if !@days_of_year || @days_of_year.empty?
      @days_of_year.include?(date.yday) || @days_of_year.include?(date.yday - TimeUtil.days_in_year(date) - 1)
    end
  
    def closest(date)
      return nil if !@days_of_year || @days_of_year.empty?
      #get some variables we need
      days_in_year = TimeUtil.days_in_year(date)
      days_left_in_this_year = days_in_year - date.yday
      days_in_next_year = TimeUtil.days_in_year(Time.utc(date.year + 1, 1, 1))
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
      distances = distances.select { |d| d > 0 }
      return nil if distances.empty?
      # return the start of the proper day
      goal = date + distances.min * IceCube::ONE_DAY
      adjust(goal, date)
    end
  
    def to_s
      'on the ' << nice_numbers(@days_of_year) << (@days_of_year.count == 1 ? ' day' : ' days') << ' of the year' unless @days_of_year.empty?
    end
  
    def to_ical
      'BYYEARDAY=' << @days_of_year.join(',') unless @days_of_year.empty?
    end
  
  end

end