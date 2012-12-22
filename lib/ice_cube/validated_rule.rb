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
    
    include Validations::OffsetFromPascha
    

    include Validations::Count
    include Validations::Until

    # Compute the next time after (or including) the specified time in respect
    # to the given schedule
    def next_time(time, schedule, closing_time)
      @time = time
      @schedule = schedule

      until finds_acceptable_time?
        # Prevent a non-matching infinite loop
        return nil if closing_time && @time.to_i > closing_time.to_i
      end

      # NOTE Uses may be 1 higher than proper here since end_time isn't
      # validated in this class.  This is okay now, since we never expose it -
      # but if we ever do - we should check that above this line, and return
      # nil if end_time is past
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
      @validations ||= {}
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

    # NOTE: optimization target, sort the rules by their type, year first
    # so we can make bigger jumps more often
    def finds_acceptable_time?
      @validations.all? do |name, validations_for_type|
        validation_accepts_or_updates_time?(validations_for_type)
      end
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

  end

end
