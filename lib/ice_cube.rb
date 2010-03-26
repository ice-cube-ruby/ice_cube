require 'yaml.rb'
require 'set.rb'

require 'ice_cube/validations/month_of_year'
require 'ice_cube/validations/day_of_year'
require 'ice_cube/validations/day_of_month'
require 'ice_cube/validations/day_of_week'
require 'ice_cube/validations/day'
require 'ice_cube/validations/hour_of_day'
require 'ice_cube/validations/minute_of_hour'
require 'ice_cube/validations/second_of_minute'

require 'ice_cube/rule'
require 'ice_cube/schedule'
require 'ice_cube/rule_occurrence'

autoload :DailyRule, 'ice_cube/rules/daily_rule'
autoload :WeeklyRule, 'ice_cube/rules/weekly_rule'
autoload :MonthlyRule, 'ice_cube/rules/monthly_rule'
autoload :YearlyRule, 'ice_cube/rules/yearly_rule'
   
autoload :HourlyRule, 'ice_cube/rules/hourly_rule'
autoload :MinutelyRule, 'ice_cube/rules/minutely_rule'
autoload :SecondlyRule, 'ice_cube/rules/secondly_rule'
   
module IceCube
  VERSION = '0.1'

  ONE_DAY = 24 * 60 * 60

  ICAL_DAYS = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']
  DAYS = { :sunday => 0, :monday => 1, :tuesday => 2, :wednesday => 3, :thursday => 4, :friday => 5, :saturday => 6 }
  MONTHS = { :january => 1, :february => 2, :march => 3, :april => 4, :may => 5, :june => 6, :july => 7, :august => 8, 
             :september => 9, :october => 10, :november => 11, :december => 12 }
end

class Time
   
  LeapYearMonthDays	=	[31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  CommonYearMonthDays	=	[31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  def is_leap?
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
  end

  def days_in_year
    is_leap? ? 366 : 365
  end

  def days_in_month
    is_leap? ? LeapYearMonthDays[month - 1] : CommonYearMonthDays[month - 1]
  end

end