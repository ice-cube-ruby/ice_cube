require 'delegate'

module IceCube

  # A way to symbolize what's necessary on the fly
  # Due to the serialization format of ice_cube, this limited implementation
  # is entirely sufficient

  class FlexibleHash < SimpleDelegator

    def initialize(hash)
      @underlying = hash
    end

    def [](key)
      case key
      when String then @underlying[key] || @underlying[key.to_sym]
      else @underlying[key] || @underlying[key.to_s]
      end
    end

  end

end
