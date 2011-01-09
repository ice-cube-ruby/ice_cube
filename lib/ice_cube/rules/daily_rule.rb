module IceCube

  class DailyRule < Rule

    # TODO repair
    # Determine whether this rule occurs on a give date.
    def in_interval?(date, start_date)
      #make sure we're in a proper interval
      day_count = date.yday - start_date.yday
      day_count % @interval == 0
    end

    def to_ical
      'FREQ=DAILY' << to_ical_base
    end

    def to_s
      to_s_base 'Daily', "Every #{@interval} days"
    end

    protected

    def default_jump(date, attempt_count = nil)
      goal = date + IceCube::ONE_DAY * @interval
      adjust(goal, date)
    end

    private

    def initialize(interval)
      super(interval)
    end

  end

end
