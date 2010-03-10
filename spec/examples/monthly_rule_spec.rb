require 'ice_cube.rb'
include IceCube

describe MonthlyRule, 'occurs_on?' do
  
  it 'should produce the correct number of days for @interval = 1' do
    start_date = Date.today
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly
    #check assumption
    schedule.occurrences(start_date + 50).count.should == 2
  end

  it 'should produce the correct number of days for @interval = 2' do
    start_date = Date.today
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly(2)
    #check assumption
    schedule.occurrences(start_date + 50).count.should == 1
  end

  it 'should produce the correct number of days for @interval = 1 with only the 1st and 15th' do
    start_date = Date.civil(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_month(1, 15)
    #check assumption (1) (15) (1) (15)
    schedule.occurrences(start_date + 50).count.should == 4
  end

  it 'should produce the correct number of days for @interval = 1 with only the 1st and last' do
    start_date = Date.civil(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_month(1, -1)
    #check assumption (1) (31) (1)
    schedule.occurrences(start_date + 50).count.should == 3 
  end

  it 'should produce the correct number of days for @interval = 1 with only the first mondays' do
    start_date = Date.civil(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [1])
    #check assumption (month 1 monday) (month 2 monday)
    schedule.occurrences(start_date + 50).count.should == 2
  end

  it 'should produce the correct number of days for @interval = 1 with only the last mondays' do
    start_date = Date.civil(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [-1])
    #check assumption (month 1 monday)
    schedule.occurrences(start_date + 40).count.should == 1
  end

  it 'should produce the correct number of days for @interval = 1 with only the first and last mondays' do
    start_date = Date.civil(2010, 1, 1)
    end_date = Date.civil(2010, 12, -1)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [1, -2])
    #check assumption (12 months - 2 dates each)
    schedule.occurrences(end_date).count.should == 24
  end
    
end
