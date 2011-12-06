module IceCube

  class ValidatedRule < Rule

    include Validations::Lock

    include Validations::HourOfDay
    include Validations::MinuteOfHour
    include Validations::SecondOfMinute
    include Validations::DayOfMonth
    include Validations::DayOfWeek
    include Validations::Day
    include Validations::MonthOfYear

    include Validations::Count
    include Validations::Until

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
