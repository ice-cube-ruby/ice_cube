require 'ice_cube.rb'
include IceCube

describe DailyRule, 'occurs_on?' do

  DAY = Date.civil(2010, 3, 1)
  
  it 'should produce the correct days for @interval = 1' do
    start_date = DAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    #check assumption
    dates = schedule.occurrences(start_date + 2)
    dates.count.should == 3
    dates.should == [DAY, DAY + 1, DAY + 2]
  end

  it 'should produce the correct days for @interval = 2' do
    start_date = DAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily(2)
    #check assumption (3) -- (1) 2 (3) 4 (5) 6 
    dates = schedule.occurrences(start_date + 5)
    dates.count.should == 3
    dates.should == [DAY, DAY + 2, DAY + 4]
  end
    
end
