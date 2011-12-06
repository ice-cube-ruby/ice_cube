module IceCube

  module Validations::HourOfDay

    include Validations::Lock

    # Add hour of day validations
    def hour_of_day(*hours)
      hours.each do |hour|
        add_lock(:hour_of_day, :hour, hour)
      end
      clobber_base_validations(:hour)
      self
    end

  end

end
