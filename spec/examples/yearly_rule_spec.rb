require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::YearlyRule, 'occurs_on?' do

  it 'should update previous interval' do
    schedule = stub(start_time: t0 = Time.utc(2013, 5, 1))
    rule = Rule.yearly(3)
    rule.interval(1)
    rule.next_time(t0 + 1, schedule, nil).should == t0 + 365.days
  end

  it 'should be able to specify complex yearly rules' do
    start_date = Time.local(2010, 7, 12, 5, 0, 0)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:april).day_of_week(:monday => [1, -1])
    #check assumption - over 1 year should be 2
    schedule.occurrences(start_date + IceCube::TimeUtil.days_in_year(start_date) * IceCube::ONE_DAY).size.should == 2
  end

  it 'should produce the correct number of days for @interval = 1' do
    start_date = Time.now
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly
    #check assumption
    schedule.occurrences(start_date + 370 * IceCube::ONE_DAY).size.should == 2
  end

  it 'should produce the correct number of days for @interval = 2' do
    start_date = Time.now
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly(2)
    #check assumption
    schedule.occurrences(start_date + 370 * IceCube::ONE_DAY).should == [start_date]
  end

  it 'should produce the correct number of days for @interval = 1 when you specify months' do
    start_date = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:january, :april, :november)
    #check assumption
    schedule.occurrences(Time.utc(2010, 12, 31)).size.should == 3
  end

  it 'should produce the correct number of days for @interval = 1 when you specify days' do
    start_date = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(155, 200)
    #check assumption
    schedule.occurrences(Time.utc(2010, 12, 31)).size.should == 2
  end

  it 'should produce the correct number of days for @interval = 1 when you specify negative days' do
    schedule = IceCube::Schedule.new(Time.utc(2010, 1, 1))
    schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(100, -1)
    #check assumption
    schedule.occurrences(Time.utc(2010, 12, 31)).size.should == 2
  end

end
