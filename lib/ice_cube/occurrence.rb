require 'forwardable'
require 'delegate'

module IceCube

  # Wraps start_time and end_time in a single concept concerning the duration.
  # This delegates to the enclosed start_time so it behaves like a normal Time
  # in almost all situations, however:
  #
  # Without ActiveSupport, it's necessary to cast the occurrence using
  # +#to_time+ before doing arithmetic, else Time will try to subtract it
  # using +#to_i+ and return a new time instead.
  #
  #     Time.now - Occurrence.new(start_time) # => 1970-01-01 01:00:00
  #     Time.now - Occurrence.new(start_time).to_time # => 3600
  #
  # When ActiveSupport::Time core extensions are loaded, it's possible to
  # subtract an Occurrence object directly from a Time to get the difference:
  #
  #     Time.now - Occurrence.new(start_time) # => 3600
  #
  class Occurrence < SimpleDelegator

    # Optimize for common methods to avoid method_missing
    extend Forwardable
    def_delegators :start_time, :to_s, :to_i, :<=>, :==
    def_delegators :to_range, :cover?, :include?, :each, :first, :last

    attr_reader :start_time, :end_time

    def initialize(start_time, end_time=nil)
      @start_time = start_time
      @end_time = end_time || start_time
      __setobj__ @start_time
    end

    def is_a?(klass)
      klass == ::Time || super
    end
    alias_method :kind_of?, :is_a?

    def intersects? other
      if other.is_a?(Occurrence) || other.is_a?(Range)
        lower_bound_1 = first + 1
        upper_bound_1 = last # exclude end
        lower_bound_2 = other.first + 1
        upper_bound_2 = other.last + 1
        if (lower_bound_2 <=> upper_bound_2) > 0
          false
        elsif (lower_bound_1 <=> upper_bound_1) > 0
          false
        else
          (upper_bound_1 <=> lower_bound_2) >= 0 and
            (upper_bound_2 <=> lower_bound_1) >= 0
        end
      else
        cover? other
      end
    end

    def comparable_time
      start_time
    end

    def duration
      end_time - start_time
    end

    def to_range
      start_time..end_time
    end

    def to_time
      start_time
    end

    def to_s
      if duration > 0
        "#{start_time} - #{end_time}"
      else
        "#{start_time}"
      end
    end

    def overnight?
      midnight = Time.new(start_time.year, start_time.month, start_time.day + 1)
      midnight < end_time
    end
  end
end
