module IceCube

  class Schedule

    def initialize(start_date)
      @rrule_occurrence_heads = []
      @exrule_occurrence_heads = []
      @rdates = []
      @exdates = []
      @start_date = start_date
    end

    # Determine whether a given date adheres to the ruleset of this schedule.
    def occurs_on?(date)
      dates = occurrences(date)
      dates.last == date
    end
    
    # Find all occurrences (following rules and exceptions) from the schedule's start date to end_date.
    def occurrences(end_date)
      exclude_dates = []
      include_dates = []
      # add all rdates, remove all exdates
      include_dates += @rdates
      exclude_dates += @exdates
      # walk through each rule, adding it to dates
      @rrule_occurrence_heads.each do |rrule_occurrence_head| 
        roc = rrule_occurrence_head
        begin 
          next if roc.to_date.nil?
          break if roc.to_date > end_date
          include_dates << roc.to_date
        end while roc = roc.succ
      end
      # walk through each exrule, removing it from dates
      @exrule_occurrence_heads.each do |exrule_occurrence_head|
        roc = exrule_occurrence_head
        begin
          next if roc.to_date.nil?
          break if roc.to_date > end_date
          exclude_dates << roc.to_date
        end while roc = roc.succ
      end
      #return a unique list of dates
      include_dates -= exclude_dates
      include_dates.sort!.uniq!
      include_dates
    end
             
    # Add a rule of any type as an recurrence in this schedule
    def add_recurrence_rule(rule)
      raise ArgumentError.new('Argument must be a valid rule') unless rule.class < Rule
      @rrule_occurrence_heads << RuleOccurrence.new(rule, @start_date)
    end

    # Add a rule of any type as an exception to this schedule
    def add_exception_rule(rule)
      raise ArgumentError.new('Argument must be a valid rule') unless rule.class < Rule
      @exrule_occurrence_heads << RuleOccurrence.new(rule, @start_date)
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
