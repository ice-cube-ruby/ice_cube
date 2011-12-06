module IceCube

  module Validations::MinuteOfHour

    include Validations::Lock

    def minute_of_hour(*minutes)
      minutes.each do |minute|
        add_lock(:minute_of_hour, :min, minute)
      end
      clobber_base_validations(:min)
      self
    end

  end

end
