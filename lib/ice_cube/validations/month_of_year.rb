module IceCube

  module Validations::MonthOfYear

    def month_of_year(*months)
      months.each do |month|
        month = TimeUtil.symbol_to_month(month) if month.is_a?(Symbol)
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

    end

  end

end
