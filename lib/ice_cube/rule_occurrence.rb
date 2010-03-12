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