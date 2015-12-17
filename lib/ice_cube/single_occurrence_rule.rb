module IceCube

  class SingleOccurrenceRule < Rule

    attr_reader :time

    def initialize(time)
      @time = TimeUtil.ensure_time time
    end

    # Always terminating
    def terminating?
      true
    end

    # Override from Rule, so any RDATE or EXDATE values may be used without HH:MM:SS defined.
    #
    def on?(time, schedule)
      next_time(time, schedule, time).to_i == time.to_i || whole_day? && same_day?(time)
    end

    def whole_day?
      time.hour == 0 && time.min == 0 && time.sec == 0
    end

    def same_day?(other)
      time.year == other.year && time.month == other.month && time.day == other.day
    end

    def next_time(t, schedule, closing_time)
      unless closing_time && closing_time < t
        time if time.to_i >= t.to_i
      end
    end

    def to_hash
      { :time => time }
    end

  end

end
