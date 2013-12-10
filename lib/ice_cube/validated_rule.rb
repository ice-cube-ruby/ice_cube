module IceCube

  class ValidatedRule < Rule

    include Validations::ScheduleLock

    include Validations::HourOfDay
    include Validations::MinuteOfHour
    include Validations::SecondOfMinute
    include Validations::DayOfMonth
    include Validations::DayOfWeek
    include Validations::Day
    include Validations::MonthOfYear
    include Validations::DayOfYear

    include Validations::Count
    include Validations::Until

    # Validations ordered for efficiency in sequence of:
    # * descending intervals
    # * boundary limits
    # * base values by cardinality (n = 60, 60, 31, 24, 12, 7)
    # * locks by cardinality (n = 365, 60, 60, 31, 24, 12, 7)
    # * interval multiplier
    VALIDATION_ORDER = [
      :year, :month, :day, :wday, :hour, :min, :sec, :count, :until,
      :base_sec, :base_min, :base_day, :base_hour, :base_month, :base_wday,
      :day_of_year, :second_of_minute, :minute_of_hour, :day_of_month,
      :hour_of_day, :month_of_year, :day_of_week,
      :interval
    ]

    def initialize(interval = 1, *)
      @validations = Hash.new
    end

    # Compute the next time after (or including) the specified time in respect
    # to the given schedule
    def next_time(time, schedule, closing_time)
      @time = time
      @schedule = schedule

      return nil unless find_acceptable_time_before(closing_time)

      @uses += 1 if @time
      @time
    end

    def to_s
      builder = StringBuilder.new
      @validations.each do |name, validations|
        validations.each do |validation|
          validation.build_s(builder)
        end
      end
      builder.to_s
    end

    def to_hash
      builder = HashBuilder.new(self)
      @validations.each do |name, validations|
        validations.each do |validation|
          validation.build_hash(builder)
        end
      end
      builder.to_hash
    end

    def to_ical
      builder = IcalBuilder.new
      @validations.each do |name, validations|
        validations.each do |validation|
          validation.build_ical(builder)
        end
      end
      builder.to_s
    end

    # Get the collection that contains validations of a certain type
    def validations_for(key)
      @validations[key] ||= []
    end

    # Fully replace validations
    def replace_validations_for(key, arr)
      if arr.nil?
        @validations.delete(key)
      else
        @validations[key] = arr
      end
    end

    # Remove the specified base validations
    def clobber_base_validations(*types)
      types.each do |type|
        @validations.delete(:"base_#{type}")
      end
    end

    private

    def finds_acceptable_time?
      validation_names.all? do |type|
        validation_accepts_or_updates_time?(@validations[type])
      end
    end

    def find_acceptable_time_before(boundary)
      until finds_acceptable_time?
        return false if past_closing_time?(boundary)
      end
      true
    end

    def validation_accepts_or_updates_time?(validations_for_type)
      res = validated_results(validations_for_type)
      # If there is any nil, then we're set - otherwise choose the lowest
      if res.any? { |r| r.nil? || r == 0 }
        true
      else
        return nil if res.all? { |r| r === true } # allow quick escaping
        res.reject! { |r| r.nil? || r == 0 || r === true }
        shift_time_by_validation(res, validations_for_type)
        false
      end
    end

    def validated_results(validations_for_type)
      validations_for_type.map do |validation|
        validation.validate(@time, @schedule)
      end
    end

    def shift_time_by_validation(res, vals)
      return unless res.min
      type = vals.first.type # get the jump type
      dst_adjust = !vals.first.respond_to?(:dst_adjust?) || vals.first.dst_adjust?
      wrapper = TimeUtil::TimeWrapper.new(@time, dst_adjust)
      wrapper.add(type, res.min)
      wrapper.clear_below(type)

      # Move over DST if blocked, no adjustments
      if wrapper.to_time <= @time
        wrapper = TimeUtil::TimeWrapper.new(wrapper.to_time, false)
        until wrapper.to_time > @time
          wrapper.add(:min, 10) # smallest interval
        end
      end

      # And then get the correct time out
      @time = wrapper.to_time
    end

    def past_closing_time?(closing_time)
      closing_time && @time > closing_time
    end

    def validation_names
      VALIDATION_ORDER & @validations.keys
    end

  end

end
