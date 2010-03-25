require File.dirname(__FILE__) + '/spec_helper'

describe MonthlyRule, 'occurs_on?' do

  WEDNESDAY = Time.utc(2010, 3, 10)
  
  it 'should produce the correct number of days for @interval = 1 with no weekdays specified' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly
    #check assumption (4 weeks in the future) (1) (2) (3) (4) (5)
    dates = schedule.occurrences(start_date + 7 * 3 * ONE_DAY)
    dates.count.should == 4
    dates.should == [start_date, start_date + 7 * ONE_DAY, start_date + 14 * ONE_DAY, start_date + 21 * ONE_DAY]    
  end

  it 'should produce the correct number of days for @interval = 1 with only weekends' do
    start_date = WEDNESDAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.day(:saturday, :sunday)
    #check assumption
    schedule.occurrences(start_date + 7 * 4 * ONE_DAY).count.should == 8
  end

  it 'should produce the correct number of days for @interval = 2 with only one day per week' do
    start_date = WEDNESDAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.day(:thursday)
    #check assumption
    schedule.occurrences(start_date + 7 * 4 * ONE_DAY).count.should == 4
  end
  
end
