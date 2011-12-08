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
    schedule = IceCube::Schedule.new(Time.new(2011, 11, 16, 11, 31, 58), :duration => 3600)
    schedule.add_recurrence_rule IceCube::Rule.minutely(60).day(4).hour_of_day(14, 15, 16).minute_of_hour(0)
    schedule.occurring_at?(Time.new(2011, 11, 17, 15, 30)).should be_false
  end

end
