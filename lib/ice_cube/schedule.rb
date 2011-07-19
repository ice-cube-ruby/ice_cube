module IceCube

  class Schedule

    attr_reader :rdates, :exdates, :start_date, :duration, :end_time

    alias :end_date :end_time
    alias :start_time :start_date

    def initialize(start_date, options = {})
      @rrule_occurrence_heads = []
      @exrule_occurrence_heads = []
      @rdates = []
      @exdates = []
      @start_date = start_date || Time.now
      raise ArgumentError.new('Duration cannot be negative') if options[:duration] && options[:duration] < 0
      @duration = options[:duration]
      raise ArgumentError.new('Start time must be before end time') if options[:end_time] && options[:end_time] < @start_date
      @end_time = options[:end_time]
    end

    # Convert the schedule to a hash, reverse of Schedule.from_hash
    def to_hash
      hash = Hash.new
      hash[:start_date] = @start_date
      hash[:rrules] = @rrule_occurrence_heads.map { |rr| rr.rule.to_hash }
      hash[:exrules] = @exrule_occurrence_heads.map { |ex| ex.rule.to_hash }
      hash[:rdates] = @rdates
      hash[:exdates] = @exdates
      hash[:duration] = @duration
      hash[:end_time] = @end_time
      hash
    end

    # Convert the schedule to yaml, reverse of Schedule.from_yaml
    def to_yaml(options = {})
      hash = to_hash
      hash[:start_date] = TimeUtil.serialize_time(hash[:start_date])
      hash[:rdates] = hash[:rdates].map { |t| TimeUtil.serialize_time(t) }
      hash[:exdates] = hash[:exdates].map { |t| TimeUtil.serialize_time(t) }
      hash[:end_time] = TimeUtil.serialize_time(hash[:end_time])
      hash.to_yaml(options)
    end

    # Create a schedule from a hash created by instance.to_hash
    def self.from_hash(hash, hash_options = {})
      options = {}
      options[:duration] = hash[:duration] if hash.has_key?(:duration)
      options[:end_time] = TimeUtil.deserialize_time(hash[:end_time]) if hash.has_key?(:end_time)
      start_date = hash_options[:start_date_override] || TimeUtil.deserialize_time(hash[:start_date])
      schedule = Schedule.new(start_date, options)
      hash[:rrules].each { |rr| schedule.add_recurrence_rule Rule.from_hash(rr) }
      hash[:exrules].each { |ex| schedule.add_exception_rule Rule.from_hash(ex) }
      hash[:rdates].each { |rd| schedule.add_recurrence_date TimeUtil.deserialize_time(rd) }
      hash[:exdates].each { |ed| schedule.add_exception_date TimeUtil.deserialize_time(ed) }
      schedule
    end

    # Create a schedule from a yaml string created by instance.to_yaml
    def self.from_yaml(str, hash_options = {})
      from_hash(YAML::load(str), hash_options)
    end

    TIME_FORMAT = '%B %e, %Y'
    SEPARATOR = ' / '
    NEWLINE = "\n"

    # use with caution
    # incomplete and not entirely tested - no time representation in dates
    # there's a lot that can happen here
    def to_s
      representation_pieces = []
      inc_dates = (@rdates - @exdates).uniq
      representation_pieces.concat inc_dates.sort.map { |d| d.strftime(TIME_FORMAT) } unless inc_dates.empty?
      representation_pieces.concat @rrule_occurrence_heads.map{ |r| r.rule.to_s } if @rrule_occurrence_heads
      representation_pieces.concat @exrule_occurrence_heads.map { |r| 'not ' << r.rule.to_s } if @exrule_occurrence_heads
      representation_pieces.concat @exdates.uniq.sort.map { |d| 'not on ' << d.strftime(TIME_FORMAT) } if @exdates
      representation_pieces << "until #{end_time.strftime(TIME_FORMAT)}" if @end_time
      representation_pieces.join(SEPARATOR)
    end

    def to_ical(force_utc = false)
      representation_pieces = ["DTSTART#{TimeUtil.ical_format(@start_date, force_utc)}"]
      representation_pieces << "DURATION:#{TimeUtil.ical_duration(@duration)}" if @duration
      inc_dates = (@rdates - @exdates).uniq
      representation_pieces.concat inc_dates.sort.map { |d| "RDATE#{TimeUtil.ical_format(d, force_utc)}" } if inc_dates.any?
      representation_pieces.concat @exdates.uniq.sort.map { |d| "EXDATE#{TimeUtil.ical_format(d, force_utc)}" } if @exdates
      representation_pieces.concat @rrule_occurrence_heads.map { |r| "RRULE:#{r.rule.to_ical}" } if @rrule_occurrence_heads
      representation_pieces.concat @exrule_occurrence_heads.map { |r| "EXRULE:#{r.rule.to_ical}" } if @exrule_occurrence_heads
      representation_pieces << "DTEND#{TimeUtil.ical_format(@end_time, force_utc)}" if @end_time
      representation_pieces.join(NEWLINE)
    end

    def occurring_at?(time)
      return false if @exdates.include?(time)
      return true if @rdates.include?(time)
      return false if any_occurring_at?(@exrule_occurrence_heads, time)
      any_occurring_at?(@rrule_occurrence_heads, time)
    end

    # Determine whether a given time adheres to the ruleset of this schedule.
    def occurs_at?(date)
      return false if @end_time && date > @end_time
      dates = occurrences(date)
      dates.last == date
    end

    # Determine whether a given date appears in the times returned by the schedule
    def occurs_on?(date)
      if defined?(ActiveSupport::TimeWithZone) && @start_date.is_a?(ActiveSupport::TimeWithZone)
        return active_support_occurs_on?(date)
      end
      # fall back to our own way of doing things
      time_format = @start_date.utc? ? :utc : :local
      self.occurrences_between(Time.send(time_format, date.year, date.month, date.day, 0, 0, 0), Time.send(time_format, date.year, date.month, date.day, 23, 59, 59)).any?
    end

    # Return all possible occurrences
    # In order to make this call, all rules in the schedule must have
    # either an until date or an occurrence count
    def all_occurrences
      find_occurrences { |head| head.all_occurrences }
    end

    # Find all occurrences until a certain date
    def occurrences(end_date)
      end_date = @end_time if @end_time && @end_time < end_date
      find_occurrences { |head| head.upto(end_date) }
    end

    # Find remaining occurrences
    def remaining_occurrences(from = Time.now)
      raise ArgumentError.new('Schedule must have an end_time to use remaining_occurrences') unless @end_time
      occurrences_between(from, @end_time)
    end

    # Find next scheduled occurrence
    def next_occurrence(from = Time.now)
      next_occurrences(1, from).first
    end

    def next_occurrences(n, from = Time.now)
      nexts = find_occurrences { |head| head.next_occurrences(n, from) }
      #Grabs the first n occurrences after the from date, remembering that there is still a
      #possibility that recurrence dates before the from time could be in the array
      nexts.select{|occurrence| occurrence > from}.first(n)
    end

    # Retrieve the first (n) occurrences of the schedule.  May return less than
    # n results, if the rules end before n results are reached.
    def first(n = nil)
      dates = find_occurrences { |head| head.first(n || 1) }
      n.nil? ? dates.first : dates.slice(0, n)
    end

    # Add a rule of any type as an recurrence in this schedule
    def add_recurrence_rule(rule)
      raise ArgumentError.new('Argument must be a valid rule') unless rule.class < Rule
      @rrule_occurrence_heads << RuleOccurrence.new(rule, @start_date, @end_time)
    end

    def rrules
      @rrule_occurrence_heads.map { |h| h.rule }
    end

    # Add a rule of any type as an exception to this schedule
    def add_exception_rule(rule)
      raise ArgumentError.new('Argument must be a valid rule') unless rule.class < Rule
      @exrule_occurrence_heads << RuleOccurrence.new(rule, @start_date, @end_time)
    end

    def exrules
      @exrule_occurrence_heads.map { |h| h.rule }
    end

    # Add an individual date to this schedule
    def add_recurrence_date(date)
      @rdates << date unless date.nil?
    end

    # Add an individual date exception to this schedule
    def add_exception_date(date)
      @exdates << date unless date.nil?
    end

    def occurrences_between(begin_time, end_time)
      # adjust to the propert end date
      end_time = @end_time if @end_time && @end_time < end_time
      # collect the occurrences
      include_dates, exclude_dates = SortedSet.new(@rdates), Set.new(@exdates)
      @rrule_occurrence_heads.each do |rrule_occurrence_head|
        include_dates.merge(rrule_occurrence_head.between(begin_time, end_time))
      end
      @exrule_occurrence_heads.each do |exrule_occurrence_head|
        exclude_dates.merge(exrule_occurrence_head.between(begin_time, end_time))
      end
      # reject all of the ones outside of the range
      include_dates.reject! { |date| exclude_dates.include?(date) || date < begin_time || date > end_time }
      include_dates.to_a
    end

    alias :rdate :add_recurrence_date
    alias rrule add_recurrence_rule
    alias exdate add_exception_date
    alias exrule add_exception_rule


    private

    # We know that start_date is a time with zone - so check referencing
    # The date in that time zone
    def active_support_occurs_on?(date)
      time = Time.zone.parse(date.to_s) # date.to_time.in_time_zone(@start_date.time_zone)
      occurrences_between(time.beginning_of_day, time.end_of_day).any?
    end

    # tell if, from a list of rule_occurrence heads, a certain time is occurring
    def any_occurring_at?(what, time)
      return false if @start_time && time < @start_time
      what.any? do |occurrence_head|
        # time is less than now and duration is less than that distance
        possibilities = occurrence_head.between(@start_date, time)
        possibilities.any? do |possibility|
          possibility + (@duration || 0) >= time
        end
      end
    end

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
