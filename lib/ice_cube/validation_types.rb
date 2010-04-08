module ValidationTypes
  
  def second_of_minute(*seconds)
    @validations[:second_of_minute] ||= []
    @validation_types[:second_of_minute] ||= SecondOfMinuteValidation.new(self)
    seconds.each do |second|
      raise ArgumentError.new('Argument must be a valid second') unless second < 60 && second >= 0
      @validations[:second_of_minute] << second
    end
    # enforce uniqueness
    @validations[:second_of_minute].uniq!
    self
  end
  
  # Specify what days of the week this rule should occur on.
  # ie: Schedule.weekly.day_of_week(:monday) would create a rule that
  # occurs every monday.
  def day(*days)
    @validations[:day] ||= []
    @validation_types[:day] ||= DayValidation.new(self)
    days.each do |day|
      if day.is_a?(Integer)
        # integer type argument
        raise ArgumentError.new('Argument must be a valid day of week (0-6)') unless day >= 0 && day <= 6
        @validations[:day] << day
      else
        # symbol type argument
        raise ArgumentError.new('Argument must be a valid day of the week') unless IceCube::DAYS.has_key?(day)
        @validations[:day] << IceCube::DAYS[day]
      end
    end
    # enforce uniqueness
    @validations[:day].uniq!
    self
  end
  
  # Specify what days of the year this rule applies to.
  # ie: Schedule.yearly(2).days_of_year(17, -1) would create a
  # rule which occurs every 17th and last day of every other year.
  # Note: you cannot combine month_of_year and day_of_year in the same rule.
  def day_of_year(*days)
    @validations[:day_of_year] ||= []
    @validation_types[:day_of_year] ||= DayOfYearValidation.new(self)
    days.each do |day|
      raise ArgumentError.new('Argument must be a valid day') if day.abs > 366
      raise ArgumentError.new('Argument must be non-zero') if day == 0
      @validations[:day_of_year] << day
    end
    # enforce uniqueness
    @validations[:day_of_year].uniq!
    self
  end
  
  # Specify what months of the year this rule applies to.  
  # ie: Schedule.yearly(2).month_of_year(:january, :march) would create a
  # rule which occurs every january and march, every other year
  # Note: you cannot combine day_of_year and month_of_year in the same rule.
  def month_of_year(*months)
    @validations[:month_of_year] ||= []
    @validation_types[:month_of_year] ||= MonthOfYearValidation.new(self)
    months.each do |month|
      if month.is_a?(Integer)
        # integer type argument
        raise ArgumentError.new('Argument must be a valid month (1-12)') unless month >= 1 && month <= 12
        @validations[:month_of_year] << month
      else
        #symbol type argument
        raise ArgumentError.new('Argument must be a valid month') unless IceCube::MONTHS.has_key?(month)
        @validations[:month_of_year] << IceCube::MONTHS[month]
      end
    end
    # enforce uniqueness
    @validations[:month_of_year].uniq!
    self
  end
  
  # Specify the day(s) of the week that this rule should occur
  # on.  ie: rule.day_of_week(:monday => [1, -1]) would mean
  # that this rule should occur on the first and last mondays of each month.
  def day_of_week(days)
    puts days[0].to_s
    @validations[:day_of_week] ||= {}
    @validation_types[:day_of_week] ||= DayOfWeekValidation.new(self)
    days.each do |day, occurrences|
      unless day.is_a?(Integer)
        raise ArgumentError.new('Argument must be a valid day of week') unless IceCube::DAYS.has_key?(day)
        day = IceCube::DAYS[day]
      end
      raise ArgumentError.new('Argument must be a valid day of week (0-6)') unless day >= 0 && day <= 6
      # add the day
      @validations[:day_of_week][day] ||= []
      @validations[:day_of_week][day].concat(occurrences)
      @validations[:day_of_week][day].uniq!
    end
    self
  end
  
  def hour_of_day(*hours)
    @validations[:hour_of_day] ||= []
    @validation_types[:hour_of_day] ||= HourOfDayValidation.new(self)
    hours.each do |hour| 
      raise ArgumentError.new('Argument must be a valid hour') unless hour < 24 && hour >= 0
      @validations[:hour_of_day] << hour
    end
    # enforce uniqueness
    @validations[:hour_of_day].uniq!
    self
  end
  
  # Specify the days of the month that this rule should
  # occur on.  ie: rule.day_of_month(1, -1) would mean that
  # this rule should occur on the first and last day of every month.
  def day_of_month(*days)
    @validations[:day_of_month] ||= []
    @validation_types[:day_of_month] ||= DayOfMonthValidation.new(self)
    days.each do |day|
      raise ArgumentError.new('Argument must be a valid date') if day.abs > 31 
      raise ArgumentError.new('Argument must be non-zero') if day == 0
      @validations[:day_of_month] << day
    end
    # enforce uniqueness
    @validations[:day_of_month].uniq!
    self
  end

  def minute_of_hour(*minutes)
    @validations[:minute_of_hour] ||= []
    @validation_types[:minute_of_hour] ||= MinuteOfHourValidation.new(self)
    minutes.each do |minute|
      raise ArgumentError.new('Argument must be a valid minute') unless minute < 60 && minute >= 0
      @validations[:minute_of_hour] << minute
    end
    # enforce uniqueness
    @validations[:minute_of_hour].uniq!
    self
  end

end