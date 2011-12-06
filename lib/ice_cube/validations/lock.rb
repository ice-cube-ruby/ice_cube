module IceCube

  module Validations::Lock

    # Lock the given times down the schedule's start_time for that position
    # These locks are all clobberable by other rules of the same #type
    # using clobber_base_validation
    def schedule_lock(*types)
      types.each { |t| add_lock(:"base_#{t}", t) }
    end

    # Add the lock as a validation
    # @param [Symbol] key - The key to use
    # @param [Symbol] type - The lock type
    # @param [Fixnum] value - The value to lock to - defaults to the schedule's start time
    def add_lock(key, type, value = nil)
      validations_for(key) << Validation.new(type, value)
    end

    # A validation used for locking time into a certain value
    class Validation

      attr_reader :type, :value

      def initialize(type, value)
        @type = type
        @value = value
      end

      INTERVALS = { :hour => 24, :min => 60, :sec => 60, :month => 12, :wday => 7 }
      def validate(time, schedule)
        return send(:"validate_#{type}_lock", time, schedule) unless INTERVALS[type]
        start = value || schedule.start_time.send(type)
        start = INTERVALS[type] + start if start < 0 # handle negative values
        start >= time.send(type) ? start - time.send(type) : INTERVALS[type] - time.send(type) + start
      end

      private

      # Needs to be custom since we don't know the days in the month
      # (meaning, its not a fixed interval)
      def validate_day_lock(time, schedule)
        start = value || schedule.start_time.day
        days_in_month = TimeUtil.days_in_month(time)
        start = days_in_month + start + 1 if start < 0 # handle negatives
        start >= time.day ? start - time.day : days_in_month - time.day + start
      end

    end

  end

end
