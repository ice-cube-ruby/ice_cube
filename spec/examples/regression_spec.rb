require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube do

  it 'should consider recurrence dates properly in find_occurreces - github issue 43' do
    s = IceCube::Schedule.new(Time.local(2011,10,1, 18, 25))
    s.add_recurrence_date(Time.local(2011,12,3,15,0,0))
    s.add_recurrence_date(Time.local(2011,12,3,10,0,0)) 
    s.add_recurrence_date(Time.local(2011,12,4,10,0,0))
    s.occurs_at?(Time.local(2011,12,3,15,0,0)).should be_true
  end

  it 'should work well with occurrences_between - issue 33' do
    schedule = IceCube::Schedule.new Time.local(2011, 10, 11, 12)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(1).hour_of_day(12).minute_of_hour(0)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(2).hour_of_day(15).minute_of_hour(0)
    schedule.add_exception_date Time.local(2011, 10, 13, 21)
    schedule.add_exception_date Time.local(2011, 10, 18, 21)
    schedule.occurrences_between(Time.local(2012, 1, 1), Time.local(2012, 12, 1))
  end

  it 'should produce the correct result for every day in may - issue 31' do
    schedule = IceCube::Schedule.new Time.now
    schedule.add_recurrence_rule IceCube::Rule.daily.month_of_year(:may)
    schedule.first(10).map(&:year).uniq.size.should == 1
  end

  it 'should not regress - issue 45' do
    rule = IceCube::Rule.monthly.day(5).hour_of_day(14).second_of_minute(0).day_of_month(13).minute_of_hour(0).month_of_year(10)
    schedule = IceCube::Schedule.new
    schedule.rrule rule
  end

  it 'should not regress - issue 40' do
    schedule = IceCube::Schedule.new(Time.local(2011, 11, 16, 11, 31, 58), :duration => 3600)
    schedule.add_recurrence_rule IceCube::Rule.minutely(60).day(4).hour_of_day(14, 15, 16).minute_of_hour(0)
    schedule.occurring_at?(Time.local(2011, 11, 17, 15, 30)).should be_false
  end

  it 'should not choke on parsing - issue 26' do
    schedule = IceCube::Schedule.new(Time.local(2011, 8, 9, 14, 52, 14))
    schedule.rrule IceCube::Rule.weekly(1).day(1, 2, 3, 4, 5)
    lambda do
      schedule = IceCube::Schedule.from_yaml(schedule.to_yaml)
    end.should_not raise_error
  end

  it 'should parse an old schedule properly' do
    file = File.read(File.dirname(__FILE__) + '/../data/issue40.yml')
    schedule = IceCube::Schedule.from_yaml(file)
    schedule.start_time.year.should == 2011
    schedule.start_time.month.should == 11
    schedule.start_time.day.should == 16
    schedule.duration.should == 3600
    schedule.rrules.should == [IceCube::Rule.minutely(60).day(4).hour_of_day(14, 15, 16).minute_of_hour(0)]
  end

  it 'should handle a simple weekly schedule - icecube issue #52' do
    rule_inst = IceCube::Rule.weekly(1).day(4)
    st = Time.new(2011, 12, 1, 18, 0, 0)
    fin = Time.new(2012, 1, 1, 18, 0, 0)
    schedule = IceCube::Schedule.new(st, :end_time => fin)
    schedule.add_recurrence_rule rule_inst
    schedule.all_occurrences.should == [
      Time.new(2011, 12, 1, 18),
      Time.new(2011, 12, 8, 18),
      Time.new(2011, 12, 15, 18),
      Time.new(2011, 12, 22, 18),
      Time.new(2011, 12, 29, 18)
    ]
  end

  it 'should be able to use count with occurrences_between falling over counts last occurrence - issue 54' do
    start_time = Time.now
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule(IceCube::Rule.daily.count(5))
    schedule.occurrences_between(start_time, start_time + 7 * IceCube::ONE_DAY).count.should == 5
    schedule.occurrences_between(start_time + 7 * IceCube::ONE_DAY, start_time + 14 * IceCube::ONE_DAY).count.should == 0
  end

  require 'active_support/time'
  it 'should exclude a date from a weekly schedule - issue #55' do
    Time.zone = 'Eastern Time (US & Canada)'
    ex = Time.zone.local(2011, 12, 27, 14)
    schedule = IceCube::Schedule.new(ex).tap do |schedule|
      schedule.add_recurrence_rule IceCube::Rule.weekly.day(:tuesday, :thursday)
      schedule.add_exception_time ex
    end
    schedule.first.should == Time.zone.local(2011, 12, 29, 14)
  end

end
