module IntegerUtil
  def self.klass
    if RUBY_VERSION.include?("2.4.")
      Integer
    else
      Fixnum
    end
  end
end
