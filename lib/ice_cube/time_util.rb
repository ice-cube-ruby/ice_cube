require 'date'

module IceCube
  module TimeUtil

    extend Deprecated

    DAYS = {
      :sunday => 0, :monday => 1, :tuesday => 2, :wednesday => 3,
      :thursday => 4, :friday => 5, :saturday => 6
    }

    MONTHS = {
      :january => 1, :february => 2, :march => 3, :april => 4, :may => 5,
      :june => 6, :july => 7, :august => 8, :september => 9, :october => 10,
      :november => 11, :december => 12
    }

    # Provides a Time.now without the usec, in the reference zone or utc offset
    def self.now(reference=Time.zone.now)
      match_zone(Time.at(Time.now.to_i), reference)
    end

    def self.match_zone(time, reference)
      return unless time = ensure_time(time)
      if reference.respond_to? :time_zone
        time.in_time_zone(reference.time_zone)
      else
        if reference.utc?
          time.utc
        elsif reference.zone
          time.getlocal
        else
          time.getlocal(reference.utc_offset)
        end
      end
    end

    # Ensure that this is either nil, or a time
    def self.ensure_time(time, date_eod = false)
      case time
      when DateTime
        warn "IceCube: DateTime support is deprecated (please use Time)"
        Time.local(time.year, time.month, time.day, time.hour, time.min, time.sec)
      when Date
        date_eod ? end_of_date(time) : time.to_time
      else
        time
      end
    end

    # Ensure that this is either nil, or a date
    def self.ensure_date(date)
      case date
      when Date then date
      else
        return Date.new(date.year, date.month, date.day)
      end
    end

    # Serialize a time appropriate for storing
    def self.serialize_time(time)
      if time.respond_to?(:time_zone)
        {:time => time.utc, :zone => time.time_zone.name}
      elsif time.is_a?(Time)
        time
      end
    end

    # Deserialize a time serialized with serialize_time
    def self.deserialize_time(time_or_hash)
      if time_or_hash.is_a?(Time)
        time_or_hash
      elsif time_or_hash.is_a?(Hash)
        time_or_hash[:time].in_time_zone(time_or_hash[:zone])
      end
    end

    # Check the deserialized time offset string against actual local time
    # offset to try and preserve the original offset for plain Ruby Time. If
    # the offset is the same as local we can assume the same original zone and
    # keep it.  If it was serialized with a different offset than local TZ it
    # will lose the zone and not support DST.
    def self.restore_deserialized_offset(time, orig_offset_str)
      return time if time.respond_to?(:time_zone) ||
                     time.getlocal(orig_offset_str).utc_offset == time.utc_offset
      warn 'IceCube: parsed Time from nonlocal TZ. Use ActiveSupport to fix DST'
      time.localtime(orig_offset_str)
    end

    # Get the beginning of a date
    def self.beginning_of_date(date, reference=nil)
      args = [date.year, date.month, date.day, 0, 0, 0]
      reference ||= Time.local(*args)
      if reference.respond_to?(:time_zone) && reference.time_zone
        reference.time_zone.local(*args)
      else
        match_zone(Time.new(*args << reference.utc_offset), reference)
      end
    end

    # Get the end of a date
    def self.end_of_date(date, reference=nil)
      args = [date.year, date.month, date.day, 23, 59, 59]
      reference ||= Time.local(*args)
      if reference.respond_to?(:time_zone) && reference.time_zone
        reference.time_zone.local(*args)
      else
        match_zone(Time.new(*args << reference.utc_offset), reference)
      end
    end

    # Convert a symbol to a numeric month
    def self.sym_to_month(sym)
      return wday = sym if (1..12).include? sym
      MONTHS.fetch(sym) do |k|
        raise ArgumentError, "Expecting Fixnum or Symbol value for month. " \
                             "No such month: #{k.inspect}"
      end
    end
    deprecated_alias :symbol_to_month, :sym_to_month

    # Convert a symbol to a wday number
    def self.sym_to_wday(sym)
      return sym if (0..6).include? sym
      DAYS.fetch(sym) do |k|
        raise ArgumentError, "Expecting Fixnum or Symbol value for weekday. " \
                             "No such weekday: #{k.inspect}"
      end
    end
    deprecated_alias :symbol_to_day, :sym_to_wday

    # Convert wday number to day symbol
    def self.wday_to_sym(wday)
      return sym = wday if DAYS.keys.include? wday
      DAYS.invert.fetch(wday) do |i|
        raise ArgumentError, "Expecting Fixnum value for weekday. " \
                             "No such wday number: #{i.inspect}"
      end
    end

    # Convert weekday from base sunday to the schedule's week start.
    def self.normalize_wday(wday, week_start)
      (wday - sym_to_wday(week_start)) % 7
    end
    deprecated_alias :normalize_weekday, :normalize_wday

    # Return the count of the number of times wday appears in the month,
    # and which of those time falls on
    def self.which_occurrence_in_month(time, wday)
      first_occurrence = ((7 - Time.utc(time.year, time.month, 1).wday) + time.wday) % 7 + 1
      this_weekday_in_month_count = ((days_in_month(time) - first_occurrence + 1) / 7.0).ceil
      nth_occurrence_of_weekday = (time.mday - first_occurrence) / 7 + 1
      [nth_occurrence_of_weekday, this_weekday_in_month_count]
    end

    # Get the days in the month for +time
    def self.days_in_month(time)
      date = Date.new(time.year, time.month, 1)
      ((date >> 1) - date).to_i
    end

    # Get the days in the following month for +time
    def self.days_in_next_month(time)
      date = Date.new(time.year, time.month, 1) >> 1
      ((date >> 1) - date).to_i
    end

    # Count the number of days to the same day of the next month without
    # overflowing shorter months
    def self.days_to_next_month(time)
      date = Date.new(time.year, time.month, time.day)
      ((date >> 1) - date).to_i
    end

    # Get a day of the month in the month of a given time without overflowing
    # into the next month. Accepts days from positive (start of month forward) or
    # negative (from end of month)
    def self.day_of_month(value, date)
      if value.to_i > 0
        [value, days_in_month(date)].min
      else
        [1 + days_in_month(date) + value, 1].max
      end
    end

    # Number of days in a year
    def self.days_in_year(time)
      date = Date.new(time.year, 1, 1)
      ((date >> 12) - date).to_i
    end

    # Number of days to n years
    def self.days_in_n_years(time, year_distance)
      date = Date.new(time.year, time.month, time.day)
      ((date >> year_distance * 12) - date).to_i
    end

    # The number of days in n months
    def self.days_in_n_months(time, month_distance)
      date = Date.new(time.year, time.month, time.day)
      ((date >> month_distance) - date).to_i
    end

    def self.dst_change(time)
      one_hour_ago = time - ONE_HOUR
      if time.dst? ^ one_hour_ago.dst?
        (time.utc_offset - one_hour_ago.utc_offset) / ONE_HOUR
      end
    end

    # A utility class for safely moving time around
    class TimeWrapper

      def initialize(time, dst_adjust = true)
        @dst_adjust = dst_adjust
        @time = time
      end

      # Get the wrapper time back
      def to_time
        @time
      end

      # DST-safely add an interval of time to the wrapped time
      def add(type, val)
        type = :day if type == :wday
        adjust do
          @time += case type
          when :year then TimeUtil.days_in_n_years(@time, val) * ONE_DAY
          when :month then TimeUtil.days_in_n_months(@time, val) * ONE_DAY
          when :day  then val * ONE_DAY
          when :hour then val * ONE_HOUR
          when :min  then val * ONE_MINUTE
          when :sec  then val
          end
        end
      end

      # Clear everything below a certain type
      CLEAR_ORDER = [:sec, :min, :hour, :day, :month, :year]
      def clear_below(type)
        type = :day if type == :wday
        CLEAR_ORDER.each do |ptype|
          break if ptype == type
          adjust do
            send(:"clear_#{ptype}")
          end
        end
      end

      private

      def adjust(&block)
        if @dst_adjust
          off = @time.utc_offset
          yield
          diff = off - @time.utc_offset
          @time += diff if diff != 0
        else
          yield
        end
      end

      def clear_sec
        @time.sec > 0 ? @time -= @time.sec : @time
      end

      def clear_min
        @time.min > 0 ? @time -= (@time.min * ONE_MINUTE) : @time
      end

      def clear_hour
        @time.hour > 0 ? @time -= (@time.hour * ONE_HOUR) : @time
      end

      # Move to the first of the month, 0 hours
      def clear_day
        @time.day > 1 ? @time -= (@time.day - 1) * ONE_DAY : @time
      end

      # Clear to january 1st
      def clear_month
        @time -= ONE_DAY
        until @time.month == 12
          @time -= TimeUtil.days_in_month(@time) * ONE_DAY
        end
        @time += ONE_DAY
      end

      def clear_year
        @time
      end

    end

  end
end
