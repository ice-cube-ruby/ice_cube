begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  # okay
end

require File.dirname(__FILE__) + '/../lib/ice_cube'

IceCube.compatibility = 12

DAY = Time.utc(2010, 3, 1)
WEDNESDAY = Time.utc(2010, 6, 23, 5, 0, 0)

WORLD_TIME_ZONES = [
  'America/Anchorage',  # -1000 / -0900
  'Europe/London',      # +0000 / +0100
  'Pacific/Auckland',   # +1200 / +1300
]

RSpec.configure do |config|
  Dir[File.dirname(__FILE__) + '/support/**/*'].each { |f| require f }

  config.include WarningHelpers

  config.before :each do |example|
    if example.metadata[:requires_active_support]
      raise 'ActiveSupport required but not present' unless defined?(ActiveSupport)
    end
  end

  config.around :each do |example|
    if zone = example.metadata[:system_time_zone]
      @orig_zone = ENV['TZ']
      ENV['TZ'] = zone
      example.run
      ENV['TZ'] = @orig_zone
    else
      example.run
    end
  end

  config.before :each do |example|
    if time_args = example.metadata[:system_time]
      case time_args
      when Array then allow(Time).to receive(:now).and_return Time.local(*time_args)
      when Time  then allow(Time).to receive(:now).and_return time_args
      end
    end
  end

  config.around :each, expect_warnings: true do |example|
    capture_warnings do
      example.run
    end
  end

end
