module IceCube

  class HourlyRule < ValidatedRule

    include Validations::HourlyInterval

    def initialize(interval = 1, week_start = :sunday)
      super
      interval(interval)
      schedule_lock(:min, :sec)
      reset
    end

  end

end
