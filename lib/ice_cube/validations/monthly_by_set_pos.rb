module IceCube

  module Validations::MonthlyBySetPos
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

      def validate(step_time, schedule)
        start_of_month = step_time.beginning_of_month
        end_of_month = step_time.end_of_month

        new_schedule = IceCube::Schedule.new(step_time - 1.month) do |s|
          s.add_recurrence_rule(IceCube::Rule.from_hash(rule.to_hash.except(:by_set_pos, :count, :until)))
        end

        occurrences = new_schedule.occurrences_between(start_of_month, end_of_month)
        index = occurrences.index(step_time)
        if index == nil
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
