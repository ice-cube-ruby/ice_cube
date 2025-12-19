module IceCube
  module Validations::HourlyBySetPos
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
        # Use the smallest expanded unit so we don't skip intra-hour candidates.
        return :sec if rule.validations[:second_of_minute]
        return :min if rule.validations[:minute_of_hour]
        :hour
      end

      def dst_adjust?
        true
      end

      def validate(step_time, start_time)
        start_of_hour = TimeUtil.build_in_zone(
          [step_time.year, step_time.month, step_time.day, step_time.hour, 0, 0], step_time
        )
        end_of_hour = TimeUtil.build_in_zone(
          [step_time.year, step_time.month, step_time.day, step_time.hour, 59, 59], step_time
        )

        # Use the schedule start_time to preserve implicit date/time anchors.
        new_schedule = IceCube::Schedule.new(start_time) do |s|
          filtered_hash = rule.to_hash.reject { |key, _| [:by_set_pos, :count, :until].include?(key) }
          # Avoid recursive BYSETPOS evaluation in the temporary schedule.
          if filtered_hash[:validations]
            filtered_hash[:validations] = filtered_hash[:validations].reject { |key, _| key == :by_set_pos }
            filtered_hash.delete(:validations) if filtered_hash[:validations].empty?
          end
          s.add_recurrence_rule(IceCube::Rule.from_hash(filtered_hash))
        end

        occurrences = new_schedule.occurrences_between(start_of_hour, end_of_hour)
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
