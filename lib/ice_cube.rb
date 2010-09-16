require 'yaml.rb'
require 'set.rb'
require 'date'

require 'ice_cube/time_util'

require 'ice_cube/validation'
require 'ice_cube/validation_types'
require 'ice_cube/rule'
require 'ice_cube/schedule'
require 'ice_cube/rule_occurrence'

module IceCube
  
  autoload :DailyRule, 'ice_cube/rules/daily_rule'
  autoload :WeeklyRule, 'ice_cube/rules/weekly_rule'
  autoload :MonthlyRule, 'ice_cube/rules/monthly_rule'
  autoload :YearlyRule, 'ice_cube/rules/yearly_rule'
   
  autoload :HourlyRule, 'ice_cube/rules/hourly_rule'
  autoload :MinutelyRule, 'ice_cube/rules/minutely_rule'
  autoload :SecondlyRule, 'ice_cube/rules/secondly_rule'

  autoload :DayValidation, 'ice_cube/validations/day'
  autoload :DayOfMonthValidation, 'ice_cube/validations/day_of_month'
  autoload :DayOfWeekValidation, 'ice_cube/validations/day_of_week'
  autoload :DayOfYearValidation, 'ice_cube/validations/day_of_year'
  autoload :HourOfDayValidation, 'ice_cube/validations/hour_of_day'
  autoload :MinuteOfHourValidation, 'ice_cube/validations/minute_of_hour'
  autoload :MonthOfYearValidation, 'ice_cube/validations/month_of_year'
  autoload :SecondOfMinuteValidation, 'ice_cube/validations/second_of_minute'

  # if you're reading this code, you've just been iced
  # http://brosicingbros.com/
  
  IceCube::ONE_DAY = 24 * 60 * 60
  IceCube::ONE_HOUR = 60 * 60
  IceCube::ONE_MINUTE = 60
  IceCube::ONE_SECOND = 1
  
  ICAL_DAYS = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA']
  DAYS = { :sunday => 0, :monday => 1, :tuesday => 2, :wednesday => 3, :thursday => 4, :friday => 5, :saturday => 6 }
  MONTHS = { :january => 1, :february => 2, :march => 3, :april => 4, :may => 5, :june => 6, :july => 7, :august => 8, 
             :september => 9, :october => 10, :november => 11, :december => 12 }
  
  include TimeUtil

end
