module IceCube

  class SecondlyRule < ValidatedRule

    include Validations::SecondlyInterval

    def initialize(interval = 1, week_start = :sunday)
      super
      interval(interval)
      reset
    end

  end

end
