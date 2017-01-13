module IceCube

  class SingleOccurrenceRule < Rule

    attr_reader :time

    def initialize(time)
      @time = TimeUtil.ensure_time(time)
    end

    # Always terminating
    def terminating?
      true
    end

    def next_time(t, schedule, closing_time)
      unless closing_time && closing_time < t
        time if time.to_i >= t.to_i
      end
    end

    def to_s
      time.to_s(:long)
    end

    def to_hash
      {
        rule_type: "IceCube::SingleOccurrenceRule",
        time: time,
      }
    end
  end
end
