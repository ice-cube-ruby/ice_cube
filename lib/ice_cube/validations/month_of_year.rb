module IceCube

  module Validations::MonthOfYear

    def month_of_year(*months)
      months.flatten.each do |month|
        unless month.is_a?(Fixnum) || month.is_a?(Symbol)
          raise ArgumentError, "expecting Fixnum or Symbol value for month, got #{month.inspect}"
        end
        month = TimeUtil.sym_to_month(month)
        validations_for(:month_of_year) << Validation.new(month)
      end
      clobber_base_validations :month
      self
    end

    class Validation

      include Validations::Lock

      attr_reader :month
      alias :value :month

      def initialize(month)
        @month = month
      end

      def type
        :month
      end

      def build_s(builder)
        builder.piece(:month_of_year) << Date::MONTHNAMES[month]
      end

      def build_hash(builder)
        builder.validations_array(:month_of_year) << month
      end

      def build_ical(builder)
        builder['BYMONTH'] << month
      end

      StringBuilder.register_formatter(:month_of_year) do |segments|
        "in #{StringBuilder.sentence(segments)}"
      end

    end

  end

end
