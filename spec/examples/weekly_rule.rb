require 'ice_cube.rb'
include IceCube

describe MonthlyRule, 'occurs_on?' do

  WEDNESDAY = Date.civil(2010, 3, 10)
  
  it 'should produce the correct number of days for @interval = 1 with no weekdays specified' do
    start_date = Date.today
    schedule = Schedule.new(start_date)
    schedule.addRecurrenceRule Rule.weekly
    #check assumption (4 weeks in the future) (1) (2) (3) (4) (5)
    schedule.occurrences(start_date + 7 * 4).count.should == 5
  end

  it 'should produce the correct number of days for @interval = 1 with only weekends' do
    start_date = WEDNESDAY
    schedule = Schedule.new(start_date)
    schedule.addRecurrenceRule Rule.weekly.day_of_week(:saturday, :sunday)
    #check assumption
    schedule.occurrences(start_date + 7 * 4).count.should == 8
  end

  it 'should produce the correct number of days for @interval = 2 with only one day per week' do
    start_date = WEDNESDAY
    schedule = Schedule.new(start_date)
    schedule.addRecurrenceRule Rule.weekly.day_of_week(:thursday)
    #check assumption
    schedule.occurrences(start_date + 7 * 4).count.should == 4
  end
  
end
