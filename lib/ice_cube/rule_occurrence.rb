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
    end
    
    #get the next occurrence of this rule
    def succ
      return nil if @rule.occurrence_count && @index >= @rule.occurrence_count # count check
      #walk through all of the successive dates, looking for the next occurrence, then return it.
      date = @date ? @date.next : @start_date # what to test next 
      begin
        return nil if @rule.until_date && date > @rule.until_date # until check
        return RuleOccurrence.new(@rule, @start_date, date, @index + 1) if @rule.occurs_on?(date, @start_date)
      end while date = date.next
    end
      
  end
  
end