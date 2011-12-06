module IceCube

  module Validations::Day

    def day(*days)
      days.each do |day|
        day = TimeUtil.symbol_to_day(day) if day.is_a?(Symbol)
        add_lock(:day, :wday, day)
      end
      clobber_base_validations(:wday, :day)
      self
    end

  end

end
