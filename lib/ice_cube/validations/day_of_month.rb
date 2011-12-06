module IceCube

  module Validations::DayOfMonth

    include Validations::Lock

    def day_of_month(*days)
      days.each do |day|
        add_lock(:day_of_month, :day, day)
      end
      clobber_base_validations(:day, :wday)
      self
    end

  end

end
