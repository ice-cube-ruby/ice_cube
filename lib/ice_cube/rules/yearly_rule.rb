module IceCube

  class YearlyRule < ValidatedRule

    include Validations::YearlyInterval

    def initialize(interval = 1, week_start = :sunday)
      super
      interval(interval)
      schedule_lock(:month, :day, :hour, :min, :sec)
      reset
    end

  end

end
