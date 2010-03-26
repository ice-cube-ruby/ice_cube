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
      raise ArgumentError.new("Rule must specify either an until date or a count to use 'all'") unless @rule.occurrence_count || @rule.until_date
      include_dates = []
      roc = self
      begin
        break if roc.nil? #go until we run out of dates
        next if roc.to_date.nil?
        include_dates << roc.to_date
      end while roc = roc.succ
      include_dates
    end
   
    #TODO - find a way to rewrite these
   
    def upto(end_date)
      include_dates = []
      roc = self
      begin
        next if roc.to_date.nil? # Handle the case where start_date is not a valid occurrence
        break if roc.to_date > end_date
        include_dates << roc.to_date
      end while roc = roc.succ
      include_dates
    end
   
    def initialize(rule, start_date, date = nil, index = 0)
      @rule = rule
      @date = date
      @start_date = start_date
      @index = index
      @date = @start_date if @date.nil? && @rule.validate_single_date(@start_date) && @rule.occurs_on?(@start_date, @start_date)
    end

    #TODO - there is a huge error here - @index should not be incremented if @date is nil
    #TODO - can this be written a bit cleaner - no do..while
    #TODO - change the name of 'next_suggestion' to something more appropriate
    #TODO - change name of occurs_on? to something like in_interval?
    
    #get the next occurrence of this rule
    def succ
      return nil if @rule.occurrence_count && @index >= @rule.occurrence_count # count check
      #walk through all of the successive dates, looking for the next occurrence (interval-valid), then return it.
      date = @date.nil? ? @rule.next_suggestion(@start_date) : @rule.next_suggestion(@date)
      begin
        return nil if @rule.until_date && date > @rule.until_date # until check
        return RuleOccurrence.new(@rule, @start_date, date, @index + 1) if @rule.occurs_on?(date, @start_date)
      end while date = @rule.next_suggestion(date)
    end
      
  end
  
end