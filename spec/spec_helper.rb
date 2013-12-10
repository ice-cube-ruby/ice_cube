begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  # okay
end

require File.dirname(__FILE__) + '/../lib/ice_cube'

DAY = Time.utc(2010, 3, 1)
WEDNESDAY = Time.utc(2010, 6, 23, 5, 0, 0)

# In tests, make Time.now have no usec so our post-serialization comparisons
# don't break
class Time

  class << self
    alias :now_original :now
  end

  def self.now
    t = now_original
    Time.new(t.year, t.month, t.day, t.hour, t.min, t.sec)
  end

end
