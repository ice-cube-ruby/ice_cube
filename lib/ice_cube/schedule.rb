module IceCube

  class Schedule

    def initialize(start_date)
      @rrules = []
      @exrules = []
      @rdates = []
      @exdates = [] #todo change these declarations to be not like this
      @start_date = start_date
    end

    # Determine whether a given date adheres to the ruleset of this schedule.
    # order of precedence in rules:
    # * Single date exceptions
    # * Single date inclusions
    # * Rule exceptions
    # * Rule recurrences
    def occurs_on?(date)
      #basic validation
      return false if @start_date > date
      #check dates
      return false if @exdates.include?(date)
      return true if @rdates.include?(date)
      #check rules
      return false if @exrules.any? { |rule| rule.occurrence_count += 1 if rule.occurs_on?(date, @start_date) }
      @rrules.any? { |rule| rule.occurrence_count += 1 if rule.occurs_on?(date, @start_date) } && !@rrules.empty?
    end

    # Find all occurrences (following rules and exceptions) from start_date to end_date
    def occurrences_between(start_date, end_date)
      raise ArgumentError.new('Start date must be less than end date') if end_date < start_date
      (start_date..end_date).select { |date| occurs_on?(date) }
    end

    # Find all occurrences (following rules and exceptions) from the schedule's start date to end_date.
    def occurrences(end_date)
      occurrences_between(@start_date, end_date)
    end

    # Return an array of the first (count) occurrences after @start_date
    # todo - guard infinite loop
    def first(count)
      so_far = 0
      dates = []
      date = @start_date
      while so_far < count
        if occurs_on?(date)
          dates << date
          so_far += 1
        end
        date = date.next
      end
      dates
    end
    
    # Add a rule of any type as an recurrence in this schedule
    def add_recurrence_rule(rule)
      raise ArgumentError.new('Argument must be a valid rule') unless rule.class < Rule
      @rrules << rule
    end

    # Add a rule of any type as an exception to this schedule
    def add_exception_rule(rule)
      raise ArgumentError.new('Argument must be a valid rule') unless rule.class < Rule
      @exrules << rule
    end

    # Add an individual date to this schedule
    def add_recurrence_date(date)
      raise ArgumentError.new('Argument must be a valid date') unless date.class == Date
      @rdates << date
    end

    # Add an individual date exception to this schedule
    def add_exception_date(date)
      raise ArgumentError.new('Argument must be a valid date') unless date.class == Date
      @exdates << date
    end
    
  end

end
