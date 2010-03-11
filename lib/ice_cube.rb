module IceCube
  VERSION = '0.1'

  ICAL_DAYS = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']
  DAYS = { :sunday => 0, :monday => 1, :tuesday => 2, :wednesday => 3, :thursday => 4, :friday => 5, :saturday => 6 }
  MONTHS = { :january => 1, :february => 2, :march => 3, :april => 4, :may => 5, :june => 6, :july => 7, :august => 8, :september => 9, :october => 10, :november => 11, :december => 12 }
end

require 'yaml.rb'

require 'ice_cube/rule'

require 'ice_cube/daily_rule'
require 'ice_cube/weekly_rule'
require 'ice_cube/monthly_rule'
require 'ice_cube/yearly_rule'

require 'ice_cube/schedule'

