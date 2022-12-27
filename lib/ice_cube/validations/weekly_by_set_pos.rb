module IceCube
  module Validations::WeeklyBySetPos
    def by_set_pos(*by_set_pos)
      by_set_pos.flatten!
      by_set_pos.each do |set_pos|
        unless (-366..366).include?(set_pos) && set_pos != 0
          raise ArgumentError, "Expecting number in [-366, -1] or [1, 366], got #{set_pos} (#{by_set_pos})"
        end
      end

      @by_set_pos = by_set_pos
      replace_validations_for(:by_set_pos, [Validation.new(by_set_pos, self)])
      self
    end

    class Validation

      attr_reader :rule, :by_set_pos

      def initialize(by_set_pos, rule)
        @by_set_pos = by_set_pos
        @rule = rule
      end

      def type
        :day
      end

      def dst_adjust?
        true
      end

      def validate(step_time, start_time)
        # Use vanilla Ruby Date objects so we can add and subtract dates across DST changes
        step_time_date = step_time.to_date
        start_day_of_week = TimeUtil.sym_to_wday(rule.week_start)
        step_time_day_of_week = step_time_date.wday
        days_delta = step_time_day_of_week - start_day_of_week
        days_to_start = days_delta >= 0 ? days_delta : 7 + days_delta
        start_of_week_date = step_time_date - days_to_start
        end_of_week_date = start_of_week_date + 6
        start_of_week = IceCube::TimeUtil.build_in_zone(
          [start_of_week_date.year, start_of_week_date.month, start_of_week_date.day, 0, 0, 0], step_time
        )
        end_of_week = IceCube::TimeUtil.build_in_zone(
          [end_of_week_date.year, end_of_week_date.month, end_of_week_date.day, 23, 59, 59], step_time
        )

        # Needs to start on the first day of the week at the step_time's hour, min, sec
        start_of_week_adjusted = IceCube::TimeUtil.build_in_zone(
          [
            start_of_week_date.year, start_of_week_date.month, start_of_week_date.day,
            step_time.hour, step_time.min, step_time.sec
          ], step_time
        )
        new_schedule = IceCube::Schedule.new(start_of_week_adjusted) do |s|
          s.add_recurrence_rule(IceCube::Rule.from_hash(rule.to_hash.except(:by_set_pos, :count, :until)))
        end

        occurrences = new_schedule.occurrences_between(start_of_week, end_of_week)
        index = occurrences.index(step_time)
        if index.nil?
          1
        else
          positive_set_pos = index + 1
          negative_set_pos = index - occurrences.length

          if @by_set_pos.include?(positive_set_pos) || @by_set_pos.include?(negative_set_pos)
            0
          else
            1
          end
        end
      end

      def build_s(builder)
        builder.piece(:by_set_pos) << by_set_pos
      end

      def build_hash(builder)
        builder[:by_set_pos] = by_set_pos
      end

      def build_ical(builder)
        builder['BYSETPOS'] << by_set_pos
      end

      nil
    end
  end
end
