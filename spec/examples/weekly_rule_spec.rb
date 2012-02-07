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

  context system_time_zone: 'America/Vancouver' do

    it 'should include nearest time in DST start hour' do
      schedule = IceCube::Schedule.new(t0 = Time.local(2013, 3, 3, 2, 30, 0))
      schedule.add_recurrence_rule IceCube::Rule.weekly
      schedule.first(3).should == [
        Time.local(2013, 3,  3, 2, 30, 0), # -0800
        Time.local(2013, 3, 10, 3, 30, 0), # -0700
        Time.local(2013, 3, 17, 2, 30, 0)  # -0700
      ]
    end

    it 'should not skip times in DST end hour' do
      schedule = IceCube::Schedule.new(t0 = Time.local(2013, 10, 27, 2, 30, 0))
      schedule.add_recurrence_rule IceCube::Rule.weekly
      schedule.first(3).should == [
        Time.local(2013, 10, 27, 2, 30, 0), # -0700
        Time.local(2013, 11,  3, 2, 30, 0), # -0700
        Time.local(2013, 11, 10, 2, 30, 0)  # -0800
      ]
    end

  end

  it 'should update previous interval' do
    schedule = double(start_time: t0 = Time.new(2013, 1, 1))
    rule = IceCube::Rule.weekly(7)
    rule.interval(2)
    rule.next_time(t0 + 1, schedule, nil).should == Time.new(2013, 1, 15)
  end

  it 'should produce the correct number of days for @interval = 1 with no weekdays specified' do
    schedule = IceCube::Schedule.new(t0 = Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    #check assumption (2 weeks in the future) (1) (2) (3) (4) (5)
    times = schedule.occurrences(t0 + (7 * 3 + 1) * IceCube::ONE_DAY)
    times.size.should == 4
  end

  it 'should produce the correct number of days for @interval = 1 with only weekends' do
    schedule = IceCube::Schedule.new(t0 = WEDNESDAY)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(:saturday, :sunday)
    #check assumption
    schedule.occurrences(t0 + 4 * IceCube::ONE_WEEK).size.should == 8
  end

  it 'should set days from symbol args' do
    schedule = IceCube::Schedule.new(t0 = WEDNESDAY)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday, :wednesday)
    schedule.rrules.first.validations_for(:day).map(&:day).should == [1, 3]
  end

  it 'should set days from array of symbols' do
    schedule = IceCube::Schedule.new(t0 = WEDNESDAY)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day([:monday, :wednesday])
    schedule.rrules.first.validations_for(:day).map(&:day).should == [1, 3]
  end

  it 'should set days from integer args' do
    schedule = IceCube::Schedule.new(t0 = WEDNESDAY)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(1, 3)
    schedule.rrules.first.validations_for(:day).map(&:day).should == [1, 3]
  end

  it 'should set days from array of integers' do
    schedule = IceCube::Schedule.new(t0 = WEDNESDAY)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day([1, 3])
    schedule.rrules.first.validations_for(:day).map(&:day).should == [1, 3]
  end

  it 'should raise an error on invalid input' do
    schedule = IceCube::Schedule.new(t0 = WEDNESDAY)
    expect { schedule.add_recurrence_rule IceCube::Rule.weekly.day(["1", "3"]) }.to raise_error
  end

  it 'should produce the correct number of days for @interval = 2 with only one day per week' do
    schedule = IceCube::Schedule.new(t0 = WEDNESDAY)
    schedule.add_recurrence_rule IceCube::Rule.weekly(2).day(:wednesday)
    #check assumption
    times = schedule.occurrences(t0 + 3 * IceCube::ONE_WEEK)
    times.should == [t0, t0 + 2 * IceCube::ONE_WEEK]
  end

  it 'should produce the correct days for @interval = 2, regardless of the start week' do
    schedule = IceCube::Schedule.new(t0 = WEDNESDAY + IceCube::ONE_WEEK)
    schedule.add_recurrence_rule IceCube::Rule.weekly(2).day(:wednesday)
    #check assumption
    times = schedule.occurrences(t0 + 3 * IceCube::ONE_WEEK)
    times.should == [t0, t0 + 2 * IceCube::ONE_WEEK]
  end

  it 'should occur every 2nd tuesday of a month' do
    schedule = IceCube::Schedule.new(t0 = Time.now)
    schedule.add_recurrence_rule IceCube::Rule.monthly.hour_of_day(11).day_of_week(:tuesday => [2])
    schedule.first(48).each do |d|
      d.hour.should == 11
      d.wday.should == 2
    end
  end

  it 'should be able to start on sunday but repeat on wednesdays' do
    schedule = IceCube::Schedule.new(t0 = Time.local(2010, 8, 1))
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday)
    schedule.first(3).should == [
      Time.local(2010, 8,  2),
      Time.local(2010, 8,  9),
      Time.local(2010, 8, 16)
    ]
  end

  it 'should start weekly rules on monday when monday is the week start' do
    schedule = IceCube::Schedule.new(t0 = Time.local(2012, 2, 7))
    schedule.add_recurrence_rule IceCube::Rule.weekly(2, :monday).day(:tuesday, :sunday)
    schedule.first(3).should == [
      Time.local(2012, 2,  7),
      Time.local(2012, 2, 12),
      Time.local(2012, 2, 21)
    ]
  end

  it 'should start weekly rules on sunday by default' do
    schedule = IceCube::Schedule.new(t0 = Time.local(2012,2,7))
    schedule.add_recurrence_rule IceCube::Rule.weekly(2).day(:tuesday, :sunday)
    schedule.first(3).should == [
      Time.local(2012, 2,  7),
      Time.local(2012, 2, 19),
      Time.local(2012, 2, 21)
    ]
  end

  it 'should validate week_start input' do
    expect { IceCube::Rule.weekly(2, :someday) }.to raise_error
  end
end
