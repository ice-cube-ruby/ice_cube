module IceCube

  class SingleOccurrenceRule < Rule

    attr_reader :time

    def initialize(time, whole_day=false)
      @time = TimeUtil.ensure_time time
      @whole_day = whole_day
    end

    # Always terminating
    def terminating?
      true
    end

    # Override from Rule, so any RDATE or EXDATE values may be used without a time defined.
    #
    def on?(time, schedule)
      next_time(time, schedule, time).to_i == time.to_i || whole_day? && same_day?(time)
    end

    def whole_day?
      @whole_day
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
