module IceCube
  module Validations
    class IntervalValidator
      def self.validate(interval)
        int = interval.to_i
        if int == 0
          raise ArgumentError, "'#{interval}' is not a valid input for interval. Please pass an integer."
        else
          int
        end
      end
    end
  end
end
