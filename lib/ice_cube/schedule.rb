require 'Set'

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
    
    # Return all possible occurrences 
    # In order to make this call, all rules in the schedule must have
    # either an until date or an occurrence count
    def all_occurrences
      find_occurrences { |head| head.all_occurrences }
    end
    
    # Find all occurrences until a certain date
    def occurrences(end_date)
      find_occurrences { |head| head.upto(end_date) }
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
   
    private
    
    # Find all occurrences (following rules and exceptions) from the schedule's start date to end_date.
    # Use custom methods to say when to end
    def find_occurrences
      exclude_dates, include_dates = Set.new(@exdates), SortedSet.new(@rdates)
      # walk through each rule, adding it to dates
      @rrule_occurrence_heads.each do |rrule_occurrence_head|
        include_dates.merge(yield(rrule_occurrence_head))
      end
      # walk through each exrule, removing it from dates
      @exrule_occurrence_heads.each do |exrule_occurrence_head|
        exclude_dates.merge(yield(exrule_occurrence_head))
      end
      #return a unique list of dates
      include_dates.reject! { |date| exclude_dates.include?(date) }
      include_dates.to_a
    end
   
  end

end
