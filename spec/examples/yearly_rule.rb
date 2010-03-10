require 'ice_cube.rb'
include IceCube

describe YearlyRule, 'occurs_on?' do
  
  it 'should produce the correct number of days for @interval = 1' do
    start_date = Date.today
    schedule = Schedule.new(start_date)
    schedule.addRecurrenceRule Rule.yearly
    #check assumption
    schedule.occurrences(start_date + 370).count.should == 2
  end

  it 'should produce the correct number of days for @interval = 2' do
    start_date = Date.today
    schedule = Schedule.new(start_date)
    schedule.addRecurrenceRule Rule.yearly(2)
    #check assumption
    schedule.occurrences(start_date + 370).count.should == 1
  end

  it 'should produce the correct number of days for @interval = 1 when you specify months' do
    start_date = Date.civil(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.addRecurrenceRule Rule.yearly.month_of_year(:january, :april, :november)
    #check assumption
    schedule.occurrences(Date.civil(2010, 12, -1)).count.should == 3
  end

  it 'should produce the correct number of days for @interval = 1 when you specify days' do
    start_date = Date.civil(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.addRecurrenceRule Rule.yearly.day_of_year(155, 200)
    #check assumption
    schedule.occurrences(Date.civil(2010, 12, -1)).count.should == 2
  end

  it 'should product the correct number of days for @interval = 1 when you specify negative days' do
    schedule = Schedule.new(Date.civil(2010, 1, 1))
    schedule.addRecurrenceRule Rule.yearly.day_of_year(100, -1)
    #check assumption
    schedule.occurrences(Date.civil(2010, 12, -1)).count.should == 2
  end
  
end
