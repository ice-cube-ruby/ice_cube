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
    st = Time.new(2011, 12, 1, 18, 0, 0)
    fin = Time.new(2012, 1, 1, 18, 0, 0)
    rule_inst = IceCube::Rule.weekly(1).day(4).until(fin)
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

  it 'should produce all occurrences between dates, not breaking on exceptions [#82]' do
    schedule = IceCube::Schedule.new(Time.new(2012, 5, 1))
    schedule.add_recurrence_rule IceCube::Rule.daily.day(:sunday, :tuesday, :wednesday, :thursday, :friday, :saturday)
    occurrences = schedule.occurrences_between(Time.new(2012, 5, 19), Time.new(2012, 5, 24))
    occurrences.should == [
      Time.new(2012, 5, 19),
      Time.new(2012, 5, 20),
      # No 21st
      Time.new(2012, 5, 22),
      Time.new(2012, 5, 23),
      Time.new(2012, 5, 24)
    ]
  end

  it 'should be able to use count with occurrences_between falling over counts last occurrence - issue 54' do
    start_time = Time.now
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule(IceCube::Rule.daily.count(5))
    schedule.occurrences_between(start_time, start_time + 7 * IceCube::ONE_DAY).count.should == 5
    schedule.occurrences_between(start_time + 7 * IceCube::ONE_DAY, start_time + 14 * IceCube::ONE_DAY).count.should == 0
  end

  it 'should produce occurrences regardless of time being specified [#81]' do
    schedule = IceCube::Schedule.new(Time.new(2012, 05, 1))
    schedule.add_recurrence_rule IceCube::Rule.daily.hour_of_day(8)
    occ = schedule.occurrences_between(Time.new(2012, 05, 20), Time.new(2012, 05, 22))
    occ.should == [
      Time.new(2012, 5, 20, 8, 0, 0),
      Time.new(2012, 5, 21, 8, 0, 0)
    ]
  end

  it 'should not include exception times due to rounding errors [#83]' do
    start_time = Time.now # start time with usec
    exdate = Time.at (start_time + IceCube::ONE_DAY).to_i # one day in the future, no usec

    schedule = IceCube::Schedule.new start_time
    schedule.rrule IceCube::Rule.daily
    schedule.first(1)[0].mday.should_not == exdate.mday
  end

  it 'should return true if a recurring schedule occurs_between? a time range [#88]' do
    start_time = Time.new(2012, 7, 7, 8)
    schedule = IceCube::Schedule.new(start_time, :duration => 2 * IceCube::ONE_HOUR)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    t1 = Time.new(2012, 7, 14, 9)
    t2 = Time.new(2012, 7, 14, 11)
    schedule.occurring_between?(t1, t2).should be_true
  end

  require 'active_support/time'

  it 'should not hang over DST [#53]' do
    schedule = IceCube::Schedule.new Time.now, :end_time => 4.years.from_now.end_of_year
    schedule.rrule IceCube::Rule.monthly
    schedule.occurrences 2.years.from_now
  end

  it 'should not hang next_time on DST boundary [#98]' do # set local to Sweden
    schedule = IceCube::Schedule.from_yaml <<-EOS
    :start_date: 2012-09-03 0:00:00.000000000 +00:00
    :end_time: 2022-09-15 0:00:00.000000000 +00:00
    :rrules:
    - :validations: {}
      :rule_type: IceCube::DailyRule
      :interval: 1
    :exrules: []
    :rtimes: []
    :extimes: []
    EOS
    occ = schedule.occurrences(Date.new(2013, 07, 13).to_time)
  end

  it 'should still include date over DST boundary [#98]' do # set local to Sweden
    schedule = IceCube::Schedule.from_yaml <<-EOS
    :start_date: 2012-09-03 15:00:00.000000000 +00:00
    :end_time: 2022-09-15 15:00:00.000000000 +00:00
    :rrules:
    - :validations: {}
      :rule_type: IceCube::DailyRule
      :interval: 1
    :exrules: []
    :rtimes: []
    :extimes: []
    EOS
    occ = schedule.occurrences(Date.new(2013, 07, 13).to_time)
    occ.detect { |o| o.year == 2013 && o.month == 3 && o.day == 31 }.should be_true
  end

  it "failing spec for hanging on DST boundary [#98]" do
    Time.zone = "Europe/London"
    first = Time.zone.parse("Sun, 31 Mar 2013 00:00:00 GMT +00:00")
    schedule = IceCube::Schedule.new(first)
    schedule.add_recurrence_rule IceCube::Rule.monthly
    next_occurance = schedule.next_occurrence(first)
  end

  it 'should exclude a date from a weekly schedule - issue #55' do
    Time.zone = 'Eastern Time (US & Canada)'
    ex = Time.zone.local(2011, 12, 27, 14)
    schedule = IceCube::Schedule.new(ex).tap do |schedule|
      schedule.add_recurrence_rule IceCube::Rule.weekly.day(:tuesday, :thursday)
      schedule.add_exception_time ex
    end
    schedule.first.should == Time.zone.local(2011, 12, 29, 14)
  end

  it 'should not raise an exception after setting the rule until to nil' do
    rule = IceCube::Rule.daily.until(Time.local(2012, 10, 1))
    rule.until(nil)

    schedule = IceCube::Schedule.new Time.local(2011, 10, 11, 12)
    schedule.add_recurrence_rule rule

    lambda {
      schedule.occurrences_between(Time.local(2012, 1, 1), Time.local(2012, 12, 1))
    }.should_not raise_error(ArgumentError, 'comparison of Time with nil failed')
  end

  it 'should not infinite loop [#109]' do
    schedule = IceCube::Schedule.new Time.new(2012, 4, 27, 0, 0, 0)
    schedule.rrule IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday).hour_of_day(0).minute_of_hour(0).second_of_minute(0)
    schedule.duration = 3600
    start_time = Time.new(2012, 10, 20, 0, 0, 0)
    end_time = Time.new(2012, 10, 20, 23, 59, 59)
    schedule.occurrences_between(start_time, end_time).first.should == start_time
  end

end
