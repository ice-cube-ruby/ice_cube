require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::WeeklyRule, 'occurs_on?' do

  it 'should not produce results for @interval = 0' do
    start_date = Time.now
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.weekly(0)
    #check assumption
    dates = schedule.occurrences(start_date + (7 * 3 + 1) * IceCube::ONE_DAY)
    dates.size.should == 0
  end

  it 'should produce the correct number of days for @interval = 1 with no weekdays specified' do
    start_date = Time.now
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    #check assumption (2 weeks in the future) (1) (2) (3) (4) (5)
    dates = schedule.occurrences(start_date + (7 * 3 + 1) * IceCube::ONE_DAY)
    dates.size.should == 4
  end

  it 'should produce the correct number of days for @interval = 1 with only weekends' do
    start_date = WEDNESDAY
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(:saturday, :sunday)
    #check assumption
    schedule.occurrences(start_date + 7 * 4 * IceCube::ONE_DAY).size.should == 8
  end

  it 'should produce the correct number of days for @interval = 2 with only one day per week' do
    start_date = WEDNESDAY
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.weekly(2).day(:wednesday)
    #check assumption
    dates = schedule.occurrences(start_date + 7*3*IceCube::ONE_DAY)
    dates.should == [start_date, start_date + 14*IceCube::ONE_DAY]
  end

  it 'should produce the correct days for @interval = 2, regardless of the start week' do
    start_date = WEDNESDAY + 7*IceCube::ONE_DAY
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.weekly(2).day(:wednesday)
    #check assumption
    dates = schedule.occurrences(start_date + 7*3*IceCube::ONE_DAY)
    dates.should == [start_date, start_date + 14*IceCube::ONE_DAY]
  end

  it 'should occurr every 2nd tuesday of a month' do
    now = Time.now
    schedule = IceCube::Schedule.new(Time.local(now.year, now.month, now.day))
    schedule.add_recurrence_rule IceCube::Rule.monthly.hour_of_day(11).day_of_week(:tuesday => [2])
    schedule.first(100).each do |d|
      d.hour.should == 11
      d.wday.should == 2
    end
  end

  it 'should occur on every first day of a month at midnight and not skip months when DST ends' do
    start_date = Time.local(2011, 8, 1)
    [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday].each_with_index do |day, index|
      schedule = IceCube::Schedule.new(start_date)
      schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_week(day => [1])
      last_date = nil
      schedule.first(100).each do |current_date|
        # should be the correct day of week
        current_date.wday.should == index
        # should be midnight
        current_date.hour.should == 0
        if last_date then
          month_interval = (current_date.year * 12 + current_date.month) - (last_date.year * 12 + last_date.month)
          # should not skip months
          month_interval.should == 1
        end
        last_date = current_date
      end
    end
  end

  it 'should be able to start on sunday but repeat on wednesdays' do
    schedule = IceCube::Schedule.new(Time.local(2010, 8, 1))
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday)
    schedule.first(3).should == [Time.local(2010, 8, 2), Time.local(2010, 8, 9), Time.local(2010, 8, 16)]
  end

  it 'should start weekly rules on monday when monday is the week start' do
    schedule = IceCube::Schedule.new(Time.local(2012,2,7))
    schedule.add_recurrence_rule IceCube::Rule.weekly(2, :monday).day(:tuesday, :sunday)
    schedule.first(3).should == [Time.local(2012,2,7), Time.local(2012,2,12), Time.local(2012,2,21)]
  end

  it 'should start weekly rules on sunday by default' do
    schedule = IceCube::Schedule.new(Time.local(2012,2,7))
    schedule.add_recurrence_rule IceCube::Rule.weekly(2).day(:tuesday, :sunday)
    schedule.first(3).should == [Time.local(2012,2,7), Time.local(2012,2,19), Time.local(2012,2,21)]
  end

end
