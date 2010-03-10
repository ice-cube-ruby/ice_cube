require 'ice_cube.rb'
include IceCube

describe DailyRule, 'occurs_on?' do

  TODAY = Date.today
  
  it 'should produce the correct number of days for @interval = 1' do
    start_date = TODAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    #check assumption
    schedule.occurrences(start_date + 2).count.should == 3
  end

  it 'should produce the correct number of days for @interval = 2' do
    start_date = TODAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily(2)
    #check assumption (3) -- (1) 2 (3) 4 (5) 6 
    schedule.occurrences(start_date + 5).count.should == 3
  end
    
end
