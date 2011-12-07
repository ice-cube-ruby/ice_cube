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
      @validations[key] = arr
    end

    # Remove the specified base validations
    def clobber_base_validations(*types)
      types.each do |type|
        @validations.delete(:"base_#{type}")
      end
    end

  end

end
