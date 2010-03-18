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
require 'ice_cube/rule_occurrence'

    
class Date
  
  # get a date object for the first of the following month  
  def first_of_next_month
    # get the number of days left in the month
    days_in_month = Date.civil(year, month, -1).mday
    days_in_month - mday + 1
  end
  
  #todo - there might be another optimization here - think about the possibility of incorporating these in the walks
  #TODO - combine the two methods below into one
  #todo - there might be a way to sort on insert in all of these, which would remove the need for map (negatives are a definite issue)
  # todo - play with the idea of next_occurrence to replace occurs_on? for individual rules
  # todo - make interval jump suggestions == maybe we don't use suggestions, we incorporate this into rules instead



end