module IceCube
  module Validations::DailyBySetPos
    def by_set_pos(*by_set_pos)
      by_set_pos.flatten!
      by_set_pos.each do |set_pos|
        unless (-366..366).cover?(set_pos) && set_pos != 0
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
        # Use the smallest expanded unit so we don't skip intra-day candidates.
        return :sec if rule.validations[:second_of_minute]
        return :min if rule.validations[:minute_of_hour]
        return :hour if rule.validations[:hour_of_day]
        :day
      end

      def dst_adjust?
        true
      end

      def validate(step_time, start_time)
        # Compute the interval bounds and build a filtered schedule that preserves
        # implicit anchors while avoiding BYSETPOS/COUNT/UNTIL truncation.
        start_of_day, end_of_day = Validations::BySetPosHelper.interval_bounds(:day, step_time)
        new_schedule = Validations::BySetPosHelper.build_filtered_schedule(rule, start_time, start_of_day)

        # Build the full candidate set for this interval, then map the selected
        # occurrence to positive/negative positions.
        occurrences = new_schedule.occurrences_between(start_of_day, end_of_day)
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
        builder.validations_array(:by_set_pos) << by_set_pos
      end

      def build_ical(builder)
        builder["BYSETPOS"] << by_set_pos
      end

      nil
    end
  end
end
