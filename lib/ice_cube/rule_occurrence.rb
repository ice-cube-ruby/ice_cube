module IceCube
  
  class RuleOccurrence
   
    include Comparable
    
    #allow to be compared to dates
    def <=>(other)
      to_time <=> other
    end
    
    def to_time
      @date
    end
       
    def all_occurrences
      raise ArgumentError.new("Rule must specify either an until date or a count to use 'all_occurrences'") unless @rule.occurrence_count || @rule.until_date || @end_time
      find_occurrences { |roc| false }
    end
   
    def between(begin_time, end_time)
      find_occurrences { |roc| roc > end_time }.select { |d| d >= begin_time }
    end

    def occurring_at?(time)
      
    end
    
    def upto(end_date)
      find_occurrences { |roc| roc > end_date }
    end

    def first(n)
      count = 0
      find_occurrences { |roc| count += 1; count > n }
    end

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
        return nil if @end_time && date > @end_time
        return nil if @rule.until_date && date > @rule.until_date # until check
        return RuleOccurrence.new(@rule, @start_date, @end_time, date, @index + 1) if @rule.in_interval?(date, @start_date)
      end while date = @rule.next_suggestion(date)
    end
    
    attr_reader :rule
   
    private

    def find_occurrences
      include_dates = []
      roc = self
      begin
        break if roc.nil? #go until we run out of dates
        next if roc.to_time.nil? #handle the case where start_date is not a valid occurrence
        break if yield(roc) #recurrence condition
        include_dates << roc.to_time
      end while roc = roc.succ
      include_dates
    end
      
    def initialize(rule, start_date, end_time, date = nil, index = 0)
      #set some variables
      @rule = rule
      @start_date = start_date
      @end_time = end_time
      @date = date
      @index = index
    end
      
  end
  
end
