begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  # okay
end

require File.dirname(__FILE__) + '/../lib/ice_cube'

DAY = Time.utc(2010, 3, 1)
WEDNESDAY = Time.utc(2010, 6, 23, 5, 0, 0)

RSpec.configure do |config|

  config.around :each, :if_active_support_time => true do |example|
    example.run if defined? ActiveSupport::Time
  end

  config.around :each, :if_active_support_time => false do |example|
    example.run unless defined? ActiveSupport::Time
  end

end
