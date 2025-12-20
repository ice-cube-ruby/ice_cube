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
        days_to_start = days_delta >= 0 ? days_delta : 7 + days_delta
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
      else
        raise ArgumentError, "Unsupported interval type: #{interval_type}"
      end
    end

    def build_filtered_schedule(rule, start_time)
      # Strip BYSETPOS/COUNT/UNTIL so the candidate set is complete, and avoid
      # recursive BYSETPOS evaluation when we rebuild the temporary rule.
      filtered_hash = rule.to_hash.reject { |key, _| [:by_set_pos, :count, :until].include?(key) }
      if filtered_hash[:validations]
        filtered_hash[:validations] = filtered_hash[:validations].reject { |key, _| key == :by_set_pos }
        filtered_hash.delete(:validations) if filtered_hash[:validations].empty?
      end

      # Use the schedule start_time to preserve implicit anchors like minute/second.
      IceCube::Schedule.new(start_time) do |s|
        s.add_recurrence_rule(IceCube::Rule.from_hash(filtered_hash))
      end
    end
  end
end
