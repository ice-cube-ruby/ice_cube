module IceCube

  class DayOfWeekValidation < Validation

    def initialize(rule)
      @days_of_week = rule.validations[:day_of_week]
      @rule = rule
    end
  
    def validate(date)
      # is it even one of the valid days?
      return true if !@days_of_week || @days_of_week.empty?
      return false unless @days_of_week.has_key?(date.wday) #shortcut
      # does this fall on one of the occurrences?
      first_occurrence = ((7 - Time.utc(date.year, date.month, 1).wday) + date.wday) % 7 + 1 #day of first occurrence of a wday in a month
      this_weekday_in_month_count = ((TimeUtil.days_in_month(date) - first_occurrence + 1) / 7.0).ceil #how many of these in the month
      nth_occurrence_of_weekday = (date.mday - first_occurrence) / 7 + 1 #what occurrence of the weekday is +date+
      @days_of_week[date.wday].include?(nth_occurrence_of_weekday) || @days_of_week[date.wday].include?(nth_occurrence_of_weekday - this_weekday_in_month_count - 1)
    end
  
    #note - temporary implementation
    def closest(date)
      return nil if !@days_of_week || @days_of_week.empty?
      while date += IceCube::ONE_DAY
        return date if validate(date)
      end
    end

    def to_s
      representation = ''
      representation << 'on the '
      representation << @days_of_week.map do |day, occ| 
        nice_numbers(occ) << ' ' << Date::DAYNAMES[day] << (occ.size != 1 ? 's' : '') unless @days_of_week.empty?
      end.join(' and the ')
      representation
    end
  
    def to_ical
      representation = 'BYDAY='
      representation << @days_of_week.map do |day, occ|
        occ.map { |o| o.to_s + IceCube::ICAL_DAYS[day] }.join(',')
      end.join(',')
      representation
    end

  end
  
end
