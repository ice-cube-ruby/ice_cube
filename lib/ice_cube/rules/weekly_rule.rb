module IceCube

  class WeeklyRule < ValidatedRule

    include Validations::WeeklyInterval

    def initialize(interval = 1)
      interval(interval)
      schedule_lock(:wday, :hour, :min, :sec)
    end

  end

end
