module IceCube

  module Validations::SecondOfMinute

    def second_of_minute(*seconds)
      seconds.each do |second|
        add_lock(:second_of_minute, :sec, second)
      end
      clobber_base_validations :sec
      self
    end

  end

end
