module IceCube

  module Validations::YearlyBySetPos

    def by_set_pos(*by_set_pos)
      return by_set_pos([by_set_pos]) if by_set_pos.is_a?(Integer)

      unless by_set_pos.nil? || by_set_pos.is_a?(Array)
        raise ArgumentError, "Expecting Array or nil value for count, got #{by_set_pos.inspect}"
      end
      by_set_pos.flatten!
      by_set_pos.each do |set_pos|
        unless (set_pos >= -366 && set_pos <= -1) ||
            (set_pos <= 366 && set_pos >= 1)
          raise ArgumentError, "Expecting number in [-366, -1] or [1, 366], got #{set_pos} (#{by_set_pos})"
        end
      end

      @by_set_pos = by_set_pos
      replace_validations_for(:by_set_pos, by_set_pos && [Validation.new(by_set_pos, self)])
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
        start_of_year = TimeUtil.start_of_year step_time
        end_of_year = TimeUtil.end_of_year step_time


        new_schedule = IceCube::Schedule.new(TimeUtil.previous_year(step_time)) do |s|
          s.add_recurrence_rule IceCube::Rule.from_hash(rule.to_hash.reject{|k, v| [:by_set_pos, :count, :until].include? k})
        end

        occurrences = new_schedule.occurrences_between(start_of_year, end_of_year)

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
