module IceCube
  
  class RuleOccurrence
   
    include Comparable
    
    #allow to be compared to dates
    def <=>(other)
      to_date <=> other.to_date
    end
    
    def to_date
      @date
    end
       
    def all_occurrences
      raise ArgumentError.new("Rule must specify either an until date or a count to use 'all_occurrences'") unless @rule.occurrence_count || @rule.until_date
      find_occurrences { |roc| false }
    end
   
    def upto(end_date)
      find_occurrences { |roc| roc.to_date > end_date }
    end

    #TODO - write this a bit cleaner - no do..while
    #TODO - change name of occurs_on? to something like in_interval?
    
    #get the next occurrence of this rule
    def succ
      return nil if @rule.occurrence_count && @index >= @rule.occurrence_count # count check
      # get the next date to walk to
      if @date.nil?
        date = @start_date if @rule.validate_single_date(@start_date)
        date = @rule.next_suggestion(@start_date) unless date
      else
        date = @rule.next_suggestion(@date)
      end
      #walk through all of the successive dates, looking for the next occurrence (interval-valid), then return it.
      begin
        return nil if @rule.until_date && date > @rule.until_date # until check
        return RuleOccurrence.new(@rule, @start_date, date, @index + 1) if @rule.occurs_on?(date, @start_date)
      end while date = @rule.next_suggestion(date)
    end
   
    private
    
    def find_occurrences
      include_dates = []
      roc = self
      begin
        break if roc.nil? #go until we run out of dates
        next if roc.to_date.nil? #handle the case where start_date is not a valid occurrence
        break if yield(roc) #recurrence condition
        include_dates << roc.to_date
      end while roc = roc.succ
      include_dates
    end
      
    def initialize(rule, start_date, date = nil, index = 0)
      @rule = rule
      @date = date
      @start_date = start_date
      @index = index
    end
      
  end
  
end