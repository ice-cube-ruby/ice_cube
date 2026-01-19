module IceCube
  module Validations::BySetPosHelper
    module_function

    def interval_bounds(interval_type, step_time, week_start: nil)
      case interval_type
      when :year
        # Build a year window in the schedule's zone so BYSETPOS is applied
        # per-year, matching RFC 5545 interval semantics.
        [
          TimeUtil.build_in_zone([step_time.year, 1, 1, 0, 0, 0], step_time),
          TimeUtil.build_in_zone([step_time.year, 12, 31, 23, 59, 59], step_time)
        ]
      when :month
        # Build a month window in the schedule's zone so BYSETPOS is applied
        # per-month, preserving DST/zone handling.
        start_of_month = TimeUtil.build_in_zone([step_time.year, step_time.month, 1, 0, 0, 0], step_time)
        eom_date = Date.new(step_time.year, step_time.month, -1)
        end_of_month = TimeUtil.build_in_zone([eom_date.year, eom_date.month, eom_date.day, 23, 59, 59], step_time)
        [start_of_month, end_of_month]
      when :week
        raise ArgumentError, "week_start is required for weekly interval bounds" unless week_start
        # Use Date arithmetic to avoid DST surprises, then rebuild in the schedule's zone.
        # WKST drives the interval boundary per RFC 5545.
        step_time_date = step_time.to_date
        start_day_of_week = TimeUtil.sym_to_wday(week_start)
        step_time_day_of_week = step_time_date.wday
        days_delta = step_time_day_of_week - start_day_of_week
        days_to_start = (days_delta >= 0) ? days_delta : 7 + days_delta
        start_of_week_date = step_time_date - days_to_start
        end_of_week_date = start_of_week_date + 6
        [
          TimeUtil.build_in_zone([start_of_week_date.year, start_of_week_date.month, start_of_week_date.day, 0, 0, 0], step_time),
          TimeUtil.build_in_zone([end_of_week_date.year, end_of_week_date.month, end_of_week_date.day, 23, 59, 59], step_time)
        ]
      when :day
        # Build a day window in the schedule's zone so BYSETPOS is applied
        # per-day (important for day-level grouping).
        [
          TimeUtil.beginning_of_date(step_time, step_time),
          TimeUtil.end_of_date(step_time, step_time)
        ]
      when :hour
        # Build an hour window in the schedule's zone so BYSETPOS is applied
        # per-hour (sub-day grouping stays intact).
        [
          TimeUtil.build_in_zone([step_time.year, step_time.month, step_time.day, step_time.hour, 0, 0], step_time),
          TimeUtil.build_in_zone([step_time.year, step_time.month, step_time.day, step_time.hour, 59, 59], step_time)
        ]
      when :min
        # Build a minute window in the schedule's zone so BYSETPOS is applied
        # per-minute (sub-hour grouping stays intact).
        [
          TimeUtil.build_in_zone([step_time.year, step_time.month, step_time.day, step_time.hour, step_time.min, 0], step_time),
          TimeUtil.build_in_zone([step_time.year, step_time.month, step_time.day, step_time.hour, step_time.min, 59], step_time)
        ]
      when :sec
        # Build a second window in the schedule's zone so BYSETPOS is applied
        # per-second (the set size is typically 1).
        second = TimeUtil.build_in_zone(
          [step_time.year, step_time.month, step_time.day, step_time.hour, step_time.min, step_time.sec], step_time
        )
        [second, second]
      else
        raise ArgumentError, "Unsupported interval type: #{interval_type}"
      end
    end

    def build_filtered_schedule(rule, start_time, interval_start)
      # Strip BYSETPOS/COUNT/UNTIL so the candidate set is complete, and avoid
      # recursive BYSETPOS evaluation when we rebuild the temporary rule.
      filtered_hash = rule.to_hash.except(:by_set_pos, :count, :until)
      if filtered_hash[:validations]
        filtered_hash[:validations] = filtered_hash[:validations].except(:by_set_pos)
        filtered_hash.delete(:validations) if filtered_hash[:validations].empty?
      end

      # Determine which components are being expanded by BYxxx rules.
      # Per RFC 5545, BYSETPOS operates on "the set of recurrence instances" which
      # "starts at the beginning of the interval defined by the FREQ rule part."
      # We must anchor the temp schedule to the interval boundary for expanded units,
      # while preserving DTSTART's value for implicit (non-expanded) units.
      v = rule.validations
      expands_day = v[:day] || v[:day_of_month] || v[:day_of_week] || v[:day_of_year]
      expands_month = v[:month_of_year]
      expands_hour = v[:hour_of_day]
      expands_min = v[:minute_of_hour]
      expands_sec = v[:second_of_minute]

      # Anchor date: determine based on which date components are expanded.
      # WeeklyRule is special: "day" expansion means weekdays within the week.
      anchor_date = if rule.is_a?(WeeklyRule)
        if expands_day
          interval_start.to_date
        else
          # Preserve the weekday from DTSTART within the current week interval.
          delta = (start_time.wday - interval_start.wday) % 7
          interval_start.to_date + delta
        end
      elsif expands_day
        # Day expansion: use interval_start's full date
        interval_start.to_date
      elsif expands_month && rule.is_a?(YearlyRule)
        # BYMONTH expansion for yearly rules: use interval_start's year/month but DTSTART's day.
        # This ensures we capture all months in the set while preserving the implicit day.
        # Note: For sub-month frequencies (daily, hourly, etc.), BYMONTH is just a filter,
        # not an expansion within the interval, so we don't shift the anchor date.
        day = [start_time.day, TimeUtil.days_in_month(Date.new(interval_start.year, interval_start.month, 1))].min
        Date.new(interval_start.year, interval_start.month, day)
      else
        start_time.to_date
      end

      # Anchor time: use interval boundary for expanded units, DTSTART for the rest.
      # This ensures the candidate set starts at the interval boundary for expanded
      # units while preserving implicit time-of-day anchors from DTSTART.
      hour = expands_hour ? interval_start.hour : start_time.hour
      min = expands_min ? interval_start.min : start_time.min
      sec = expands_sec ? interval_start.sec : start_time.sec

      # Preserve sub-second precision from DTSTART to ensure occurrences.index(step_time)
      # can find exact matches when DTSTART has fractional seconds.
      sec_with_subsec = sec + TimeUtil.subsec(start_time)

      schedule_start = TimeUtil.build_in_zone(
        [anchor_date.year, anchor_date.month, anchor_date.day, hour, min, sec_with_subsec],
        start_time
      )

      IceCube::Schedule.new(schedule_start) do |s|
        s.add_recurrence_rule(IceCube::Rule.from_hash(filtered_hash))
      end
    end
  end
end
