module IceCube

  class MonthOfYearValidation < Validation
  
    def initialize(rule)
      @months_of_year = rule.validations[:month_of_year]
    end
  
    def validate(date)
      return true if !@months_of_year || @months_of_year.empty?
      @months_of_year.include?(date.month)
    end
  
    def closest(date)
      return nil if !@months_of_year || @months_of_year.empty?
      # turn months into month of year
      # month > 12 should fall into the next year
      months = @months_of_year.map do |m|
        m > date.month ? m - date.month : 12 - date.month + m
      end
      months.compact!
      # go to the closest distance away
      goal = date
      months.min.times { goal += TimeUtil.days_in_month(goal) * IceCube::ONE_DAY }
      adjust(goal, date)
    end

    def to_s
      'in ' << @months_of_year.map { |m| Date::MONTHNAMES[m] }.join(', ') unless @months_of_year.empty?
    end

    def to_ical
      'BYMONTH=' << @months_of_year.join(',') unless @months_of_year.empty?
    end
    
  end
  
end