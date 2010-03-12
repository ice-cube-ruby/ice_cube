module IceCube

  class Schedule

    def initialize(start_date)
      @rrules = []
      @exrules = []
      @rdates = []
      @exdates = []
      @start_date = start_date
    end

    # Determine whether a given date adheres to the ruleset of this schedule.
    # order of precedence in rules:
    # * Single date exceptions
    # * Single date inclusions
    # * Rule exceptions
    # * Rule recurrences
    #def occurs_on?(date)
    #  #basic validation
    #  return false if @start_date > date
    #  #check dates
    #  return false if @exdates.include?(date)
    #  return true if @rdates.include?(date)
    #  #check validations
    #  return false if @exrules.any? { |rule| rule.occurs_on?(date, @start_date) }
    #  @rrules.any? { |rule| rule.occurs_on?(date, @start_date) } && !@rrules.empty?
    #end

    def occurs_on?(date)
      occurrences_finder(@start_date, date) do |date_found| 
        return true if date == date_found
      end
      return false
    end
    
    # Find all occurrences (following rules and exceptions) from the schedule's start date to end_date.
    def occurrences(end_date)
      occurrences_between(@start_date, end_date)
    end

    # Find all occurrences (following rules and exceptions) from start_date to end_date    
    def occurrences_between(start_date, end_date) 
      dates = []
      occurrences_finder(start_date, end_date) { |date| dates << date }
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

  private
   
    def occurrences_finder(start_date, end_date)
      rrules_occurrences = {}
      exrules_occurrences = {}
      (start_date..end_date).each do |date|
        #basic validation
        success = nil
        success = false if date < @start_date || date < start_date
        #check individual dates
        success = false if @exdates.include?(date)
        success = true if @rdates.include?(date) && success.nil?
        #check exruless
        @exrules.each do |rule|
          exrules_occurrences[rule.object_id] = 0 unless exrules_occurrences.has_key?(rule.object_id)
          next unless rule.occurs_on?(date, @start_date) #skip ones that don't pass
          exrules_occurrences[rule.object_id] += 1
          #weird validations
          next if rule.occurrence_count && exrules_occurrences[rule.object_id] > rule.occurrence_count
          #set success to false if appropriate
          success = false
        end
        #check rrule
        @rrules.each do |rule| 
          rrules_occurrences[rule.object_id] = 0 unless rrules_occurrences.has_key?(rule.object_id)
          next unless rule.occurs_on?(date, @start_date) #skip ones that don't passs
          rrules_occurrences[rule.object_id] += 1
          #weird validations
          next if rule.occurrence_count && rrules_occurrences[rule.object_id] > rule.occurrence_count
          #set success to true if appropriate
          success = true if success.nil?
        end
        yield(date) if success == true
      end
    end
   
  end

end
