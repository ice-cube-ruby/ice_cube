module IceCube

  class Schedule

    # Get the start time
    attr_accessor :start_time
    alias :start_date :start_time
    alias :start_date= :start_time=
    
    # Get the duration
    attr_accessor :duration

    # Get the end time
    attr_accessor :end_time
    alias :end_date :end_time

    # Get the recurrence rules
    attr_reader :recurrence_rules
    alias :rrules :recurrence_rules

    # Get the exception rules
    attr_reader :exception_rules
    alias :exrules :exception_rules

    # Create a new schedule
    def initialize(start_time = nil, options = {})
      @start_time = start_time || Time.now
      @end_time = options[:end_time]
      @duration = options[:duration]
      @recurrence_rules = []
      @exception_rules = []
    end

    # Add a recurrence time to the schedule
    def add_recurrence_time(time)
      return nil if time.nil?
      rule = SingleOccurrenceRule.new(time)
      add_recurrence_rule rule
      time
    end
    alias :rdate :add_recurrence_time
    alias :add_recurrence_date :add_recurrence_time

    # Add an exception time to the schedule
    def add_exception_time(time)
      return nil if time.nil?
      rule = SingleOccurrenceRule.new(time)
      add_exception_rule rule
      time
    end
    alias :exdate :add_exception_time
    alias :add_exception_date :add_exception_time

    # Add a recurrence rule to the schedule
    def add_recurrence_rule(rule)
      @recurrence_rules << rule
    end
    alias :rrule :add_recurrence_rule

    # Remove a recurrence rule
    def remove_recurrence_rule(rule)
      deletions = []
      recurrence_rules.delete_if { |r| deletions << r if rule == r }
      deletions
    end

    # Add an exception rule to the schedule
    def add_exception_rule(rule)
      @exception_rules << rule
    end
    alias :exrule :add_exception_rule

    # Remove an exception rule
    def remove_exception_rule(rule)
      deletions = []
      exception_rules.delete_if { |r| deletions << r if rule == r }
      deletions
    end

    # Get the recurrence times that are on the schedule
    def recurrence_times
      recurrence_rules.select { |r| r.is_a?(SingleOccurrenceRule) }.map(&:time)
    end
    alias :rdates :recurrence_times
    alias :recurrence_dates :recurrence_times

    # TODO re-implement
    def remove_recurrence_time(time)
      found = false
      recurrence_rules.delete_if do |rule|
        found = true if rule.is_a?(SingleOccurrenceRule) && rule.time == time
      end
      time if found
    end
    alias :remove_recurrence_date :remove_recurrence_time
    alias :remove_rdate :remove_recurrence_time

    # Get the exception times that are on the schedule
    def exception_times
      exception_rules.select { |r| r.is_a?(SingleOccurrenceRule) }.map(&:time)
    end
    alias :exdates :exception_times
    alias :exception_dates :exception_times

    # TODO re-implement
    def remove_exception_time(time)
      found = false
      exception_rules.delete_if do |rule|
        found = true if rule.is_a?(SingleOccurrenceRule) && rule.time == time
      end
      time if found
    end
    alias :remove_exception_date :remove_exception_time
    alias :remove_exdate :remove_exception_time

    # Get all of the occurrences from the start_time up until a
    # given Time
    def occurrences(closing_time)
      find_occurrences(start_time, closing_time)
    end

    # All of the occurrences
    def all_occurrences
      find_occurrences(start_time)
    end

    # The next n occurrences after now
    def next_occurrences(num, from = Time.now)
      find_occurrences(from + 1, nil, num)
    end

    # The next occurrence after now (overridable)
    def next_occurrence(from = Time.now)
      find_occurrences(from + 1, nil, 1).first
    end

    # The remaining occurrences (same requirements as all_occurrences)
    def remaining_occurrences(from = Time.now)
      find_occurrences(from)
    end

    # Occurrences between two times
    def occurrences_between(begin_time, closing_time)
      find_occurrences(begin_time, closing_time)
    end

    # Return a boolean indicating if an occurrence falls between
    # two times
    def occurs_between?(begin_time, closing_time)
      !find_occurrences(begin_time, closing_time, 1).empty?
    end

    # Return a boolean indicating if an occurrence falls on a certain date
    def occurs_on?(date)
      begin_time = TimeUtil.beginning_of_date(date)
      closing_time = TimeUtil.end_of_date(date)
      occurs_between?(begin_time, closing_time)
    end

    # Determine if the schedule is occurring at a given time
    def occurring_at?(time)
      if duration
        return false if exception_time?(time)
        occurs_between?(time - duration + 1, time)
      else
        occurs_at?(time)
      end
    end

    # Determine if the schedule occurs at a specific time
    def occurs_at?(time)
      occurs_between?(time, time)
    end

    # Get the first n occurrences, or the first occurrence if n is skipped
    def first(n = nil)
      occurrences = find_occurrences start_time, nil, n || 1
      n.nil? ? occurrences.first : occurrences
    end

    private

    # Reset all rules for another run
    def reset
      recurrence_rules.each(&:reset)
      exception_rules.each(&:reset)
    end

    # Find all of the occurrences for the schedule between opening_time
    # and closing_time
    def find_occurrences(opening_time, closing_time = nil, limit = nil)
      reset
      answers = []
      # ensure the bounds are proper
      if end_time
        closing_time = end_time unless closing_time && closing_time < @end_time
      end
      opening_time = start_time if opening_time < start_time
      # And off we go
      time = opening_time
      loop do
        res = next_time(time)
        break unless res
        break if closing_time && res > closing_time
        answers << res
        break if limit && answers.length == limit
        time = res + 1
      end
      # and return our answers
      answers
    end

    # Get the next time after (or including) a specific time
    def next_time(time)
      min_time = nil
      loop do
        recurrence_rules.each do |rule|
          begin
            if res = rule.next_time(time, self)
              if min_time.nil? || res < min_time
                min_time = res
              end
            end
          # Certain exceptions mean this rule no longer wants to play
          rescue CountExceeded, UntilExceeded
            next
          end
        end
        # If there is no match, return nil
        return nil unless min_time
        # Now make sure that its not an exception_time, and if it is
        # then keep looking
        if exception_time?(min_time)
          time = min_time + 1
          min_time = nil
          next
        end
        # Break, we're done
        break
      end
      min_time
    end

    # Return a boolean indicating whether or not a specific time
    # is excluded from the schedule
    def exception_time?(time)
      exception_rules.any? do |rule|
        rule.on?(time, self)
      end
    end

  end

end
