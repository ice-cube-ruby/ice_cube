module IceCube

  class StringBuilder

    # TODO reimplement with linkedlist if desired more efficient
    def initialize
      @arr = []
    end

    def prepend(s)
      @arr.unshift(s)
    end

    def append(s)
      @arr << s
    end
    alias :<< :append

    def to_s
      @arr.join ' '
    end

  end

end
