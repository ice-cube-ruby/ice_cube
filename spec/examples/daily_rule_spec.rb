require File.dirname(__FILE__) + '/spec_helper'

describe IceCube::DailyRule, 'occurs_on?' do

  it 'should produce the correct days for @interval = 1' do
    start_date = DAY
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.daily
    #check assumption
    dates = schedule.occurrences(start_date + 2 * IceCube::ONE_DAY)
    dates.size.should == 3
    dates.should == [DAY, DAY + 1 * IceCube::ONE_DAY, DAY + 2 * IceCube::ONE_DAY]
  end

  it 'should produce the correct days for @interval = 2' do
    start_date = DAY
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.daily(2)
    #check assumption (3) -- (1) 2 (3) 4 (5) 6
    dates = schedule.occurrences(start_date + 5 * IceCube::ONE_DAY)
    dates.size.should == 3
    dates.should == [DAY, DAY + 2 * IceCube::ONE_DAY, DAY + 4 * IceCube::ONE_DAY]
  end

  it 'should produce the correct days for interval of 4 day with hour and minute of day set' do
    start_date = DAY
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.daily(4).hour_of_day(5).minute_of_hour(45)

    #check assumption 2 -- 1 (2) (3) (4) 5 (6)
    dates = schedule.occurrences(start_date + 5 * IceCube::ONE_DAY)
    dates.size.should == 2
    dates.should == [DAY + 5.hours + 45.minutes, DAY + 4 * IceCube::ONE_DAY + 5.hours + 45.minutes]
  end

end
