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

  def closest_day_of_year(days_of_year)
    #get some variables we need
    days_in_year = Date.civil(year, 12, -1).yday
    days_left_in_this_year = days_in_year - yday
    days_in_next_year = Date.civil(year + 1, 12, -1).yday
    # create a list of distances
    distances = []
    days_of_year.each do |d|
      if d > 0
        distances << d - yday #today is 1, we want 20 (19)
        distances << days_left_in_this_year + d #(364 + 20)
      elsif d < 0
        distances << (days_in_year + d + 1) - yday #today is 300, we want -1
        distances << (days_in_next_year + d + 1) + days_left_in_this_year #today is 300, we want -70
      end
    end
    #return the lowest distance
    distances = distances.select { |d| d > 0 }
    distances.empty? ? nil : distances.min
  end
  
  def closest_day_of_month(days_of_month)
    #get some variables we need
    days_in_month = Date.civil(year, month, -1).mday
    days_left_in_this_month = days_in_month - mday
    next_month, next_year = month == 12 ? [1, year + 1] : [month + 1, year] #clean way to wrap over years
    days_in_next_month = Date.civil(next_year, next_month, -1).mday
    # create a list of distances
    distances = []
    days_of_month.each do |d|
      if d > 0
        distances << d - mday #today is 1, we want 20 (19)
        distances << days_left_in_this_month + d #(364 + 20)
      elsif d < 0
        distances << (days_in_month + d + 1) - mday #today is 30, we want -1
        distances << (days_in_next_month + d + 1) + days_left_in_this_month #today is 300, we want -70
      end
    end
    #return the lowest distance
    distances = distances.select { |d| d > 0 }
    distances.empty? ? nil : distances.min
  end

end