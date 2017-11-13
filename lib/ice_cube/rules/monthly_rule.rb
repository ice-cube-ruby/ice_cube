module IceCube

  class MonthlyRule < ValidatedRule

    include Validations::HourOfDay
    include Validations::MinuteOfHour
    include Validations::SecondOfMinute
    include Validations::DayOfMonth
    include Validations::DayOfWeek
    include Validations::Day
    include Validations::MonthOfYear
    # include Validations::DayOfYear    # n/a

    include Validations::MonthlyInterval
    include Validations::MonthlyBySetPos

    def day_of_year(*_)
      # NO-OP
      self
    end

    def initialize(interval = 1)
      super
      interval(interval)
      schedule_lock(:day, :hour, :min, :sec)
      reset
    end

  end

end
