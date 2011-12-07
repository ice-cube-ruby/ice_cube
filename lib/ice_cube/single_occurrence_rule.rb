module IceCube

  class SingleOccurrenceRule < Rule

    attr_reader :time

    def initialize(time)
      @time = time
    end

    def next_time(t, schedule)
      time if time >= t
    end

    def to_hash
      { :time => time }
    end

  end

end
