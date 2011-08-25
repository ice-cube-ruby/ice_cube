module IceCube
  
  class RuleOccurrence

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

    def upto(end_date)
      find_occurrences { |roc| roc > end_date }
    end

    # Break after the first occurrence after now
    def next_occurrence(from)
      next_occurrences(1, from).first
    end

    # Break after the first n occurrences after now
    def next_occurrences(n, from)
      found_all = false
      num_found = 0
      nexts = find_occurrences do |roc|
        find = roc > from
        num_found += 1 if find
        success = found_all
        found_all = num_found == n
        success
      end
      #Since the above returns all up to and including the next N that were requested, we need
      #to grab the last n, making sure to prune out ones that were actually before the from time
      nexts.last(n).select{|occurrence| occurrence > from}
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
      # walk through all of the successive dates, looking for the next occurrence (interval-valid), then return it.
      begin
        return nil if @end_time && date > @end_time
        return nil if @rule.until_date && date > @rule.until_date # until check
        next unless @rule.in_interval?(date, @start_date)
        return nil if yield(date)
        return RuleOccurrence.new(@rule, @start_date, @end_time, date, @index + 1)
      end while date = @rule.next_suggestion(date)
    end
    
    attr_reader :rule
    attr_accessor :start_date
   
    private

    def find_occurrences(&block)
      include_dates = []
      roc = self
      begin
        break if roc.nil? #go until we run out of dates
        next if roc.to_time.nil? #handle the case where start_date is not a valid occurrence
        include_dates << roc.to_time
      end while roc = roc.succ(&block)
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
