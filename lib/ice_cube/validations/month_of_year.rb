module IceCube

  module Validations::MonthOfYear

    def month_of_year(*months)
      months.each do |month|
        month = TimeUtil.symbol_to_month(month) if month.is_a?(Symbol)
        add_lock(:month_of_year, :month, month)
      end
      clobber_base_validations :month
      self
    end

  end

end
