module IceCube

  module Validations::Until

    def until(time)
      replace_validations_for(:until, [Validation.new(time)])
      self
    end

    class Validation

      attr_reader :time

      def initialize(time)
        @time = time
      end

      def validate(t, schedule)
        raise UntilExceeded if t > time 
      end

    end
      
  end

end
