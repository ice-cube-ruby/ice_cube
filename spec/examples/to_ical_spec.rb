require File.dirname(__FILE__) + '/../spec_helper'
require 'active_support/time'

describe IceCube, 'to_ical' do

  it 'should return a proper ical representation for a basic daily rule' do
    rule = IceCube::Rule.daily
    rule.to_ical.should == "FREQ=DAILY"
  end

  it 'should return a proper ical representation for a basic monthly rule' do
    rule = IceCube::Rule.weekly
    rule.to_ical.should == "FREQ=WEEKLY"
  end

  it 'should return a proper ical representation for a basic monthly rule' do
    rule = IceCube::Rule.monthly
    rule.to_ical.should == "FREQ=MONTHLY"
  end

  it 'should return a proper ical representation for a basic yearly rule' do
    rule = IceCube::Rule.yearly
    rule.to_ical.should == "FREQ=YEARLY"
  end

  it 'should return a proper ical representation for a basic hourly rule' do
    rule = IceCube::Rule.hourly
    rule.to_ical.should == "FREQ=HOURLY"
  end

  it 'should return a proper ical representation for a basic minutely rule' do
    rule = IceCube::Rule.minutely
    rule.to_ical.should == "FREQ=MINUTELY"
  end

  it 'should return a proper ical representation for a basic secondly rule' do
    rule = IceCube::Rule.secondly
    rule.to_ical.should == "FREQ=SECONDLY"
  end

  it 'should be able to serialize a .day rule to_ical' do
    rule = IceCube::Rule.daily.day(:monday, :tuesday)
    rule.to_ical.should == "FREQ=DAILY;BYDAY=MO,TU"
  end

  it 'should be able to serialize a .day_of_week rule to_ical' do
    rule = IceCube::Rule.daily.day_of_week(:tuesday => [-1, -2])
    rule.to_ical.should == "FREQ=DAILY;BYDAY=-1TU,-2TU"
  end

  it 'should be able to serialize a .day_of_month rule to_ical' do
    rule = IceCube::Rule.daily.day_of_month(23)
    rule.to_ical.should == "FREQ=DAILY;BYMONTHDAY=23"
  end

  it 'should be able to serialize a .day_of_year rule to_ical' do
    rule = IceCube::Rule.daily.day_of_year(100,200)
    rule.to_ical.should == "FREQ=DAILY;BYYEARDAY=100,200"
  end

  it 'should be able to serialize a .month_of_year rule to_ical' do
    rule = IceCube::Rule.daily.month_of_year(:january, :april)
    rule.to_ical.should == "FREQ=DAILY;BYMONTH=1,4"
  end

  it 'should be able to serialize a .hour_of_day rule to_ical' do
    rule = IceCube::Rule.daily.hour_of_day(10, 20)
    rule.to_ical.should == "FREQ=DAILY;BYHOUR=10,20"
  end

  it 'should be able to serialize a .minute_of_hour rule to_ical' do
    rule = IceCube::Rule.daily.minute_of_hour(5, 55)
    rule.to_ical.should == "FREQ=DAILY;BYMINUTE=5,55"
  end

  it 'should be able to serialize a .second_of_minute rule to_ical' do
    rule = IceCube::Rule.daily.second_of_minute(0, 15, 30, 45)
    rule.to_ical.should == "FREQ=DAILY;BYSECOND=0,15,30,45"
  end

  it 'should be able to collapse a combination day_of_week and day' do
    rule = IceCube::Rule.daily.day(:monday, :tuesday).day_of_week(:monday => [1, -1])
    ['FREQ=DAILY;BYDAY=TU,1MO,-1MO', 'FREQ=DAILY;BYDAY=1MO,-1MO,TU'].include?(rule.to_ical).should be_true
  end

  it 'should be able to serialize of .day_of_week rule to_ical with multiple days' do
    rule = IceCube::Rule.daily.day_of_week(:monday => [1, -1], :tuesday => [2]).day(:wednesday)
    [
      'FREQ=DAILY;BYDAY=WE,1MO,-1MO,2TU',
      'FREQ=DAILY;BYDAY=1MO,-1MO,2TU,WE',
      'FREQ=DAILY;BYDAY=2TU,1MO,-1MO,WE',
      'FREQ=DAILY;BYDAY=WE,2TU,1MO,-1MO',
      'FREQ=DAILY;BYDAY=2TU,WE,1MO,-1MO'
    ].include?(rule.to_ical).should be_true
  end

  it 'should be able to serialize a base schedule to ical in local time' do
    Time.zone = "Eastern Time (US & Canada)"
    schedule = IceCube::Schedule.new(Time.zone.local(2010, 5, 10, 9, 0, 0))
    schedule.to_ical.should == "DTSTART;TZID=EDT:20100510T090000"
  end

  it 'should be able to serialize a base schedule to ical in UTC time' do
    schedule = IceCube::Schedule.new(Time.utc(2010, 5, 10, 9, 0, 0))
    schedule.to_ical.should == "DTSTART:20100510T090000Z"
  end

  it 'should be able to serialize a schedule with one rrule' do
    Time.zone = 'Pacific Time (US & Canada)'
    schedule = IceCube::Schedule.new(Time.zone.local(2010, 5, 10, 9, 0, 0))
    schedule.add_recurrence_rule IceCube::Rule.weekly
    # test equality
    expectation = "DTSTART;TZID=PDT:20100510T090000\n"
    expectation << 'RRULE:FREQ=WEEKLY'
    schedule.to_ical.should == expectation
  end

  it 'should be able to serialize a schedule with multiple rrules' do
    Time.zone = 'Eastern Time (US & Canada)'
    schedule = IceCube::Schedule.new(Time.zone.local(2010, 10, 20, 4, 30, 0))
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(:monday => [2, -1])
    schedule.add_recurrence_rule IceCube::Rule.hourly
    expectation = "DTSTART;TZID=EDT:20101020T043000\n"
    expectation << "RRULE:FREQ=WEEKLY;BYDAY=2MO,-1MO\n"
    expectation << "RRULE:FREQ=HOURLY"
    schedule.to_ical.should == expectation
  end

  it 'should be able to serialize a schedule with one exrule' do
    Time.zone ='Pacific Time (US & Canada)'
    schedule = IceCube::Schedule.new(Time.zone.local(2010, 5, 10, 9, 0, 0))
    schedule.add_exception_rule IceCube::Rule.weekly
    # test equality
    expectation= "DTSTART;TZID=PDT:20100510T090000\n"
    expectation<< 'EXRULE:FREQ=WEEKLY'
    schedule.to_ical.should == expectation
  end

  it 'should be able to serialize a schedule with multiple exrules' do
    Time.zone ='Eastern Time (US & Canada)'
    schedule = IceCube::Schedule.new(Time.zone.local(2010, 10, 20, 4, 30, 0))
    schedule.add_exception_rule IceCube::Rule.weekly.day_of_week(:monday => [2, -1])
    schedule.add_exception_rule IceCube::Rule.hourly
    expectation = "DTSTART;TZID=EDT:20101020T043000\n"
    expectation<< "EXRULE:FREQ=WEEKLY;BYDAY=2MO,-1MO\n"
    expectation<< "EXRULE:FREQ=HOURLY"
    schedule.to_ical.should == expectation
  end

  it 'should be able to serialize a schedule with an rtime' do
    schedule = IceCube::Schedule.new(Time.utc(2010, 5, 10, 10, 0, 0))
    schedule.add_recurrence_time Time.utc(2010, 6, 20, 5, 0, 0)
    # test equality
    expectation = "DTSTART:20100510T100000Z\n"
    expectation << "RDATE:20100620T050000Z"
    schedule.to_ical.should == expectation
  end

  it 'should be able to serialize a schedule with an exception time' do
    schedule = IceCube::Schedule.new(Time.utc(2010, 5, 10, 10, 0, 0))
    schedule.add_exception_time Time.utc(2010, 6, 20, 5, 0, 0)
    # test equality
    expectation = "DTSTART:20100510T100000Z\n"
    expectation << "EXDATE:20100620T050000Z"
    schedule.to_ical.should == expectation
  end

  it 'should be able to serialize a schedule with a duration' do
    schedule = IceCube::Schedule.new(Time.utc(2010, 5, 10, 10), :duration => 3600)
    expectation = "DTSTART:20100510T100000Z\n"
    expectation << 'DTEND:20100510T110000Z'
    schedule.to_ical.should == expectation
  end

  it 'should be able to serialize a schedule with a duration - more odd duration' do
    schedule = IceCube::Schedule.new(Time.utc(2010, 5, 10, 10), :duration => 3665)
    expectation = "DTSTART:20100510T100000Z\n"
    expectation << 'DTEND:20100510T110105Z'
    schedule.to_ical.should == expectation
  end

  it 'should be able to serialize a schedule with an end time' do
    schedule = IceCube::Schedule.new(Time.utc(2010, 5, 10, 10), :end_time => Time.utc(2010, 5, 10, 20))
    expectation = "DTSTART:20100510T100000Z\n"
    expectation << "DTEND:20100510T200000Z"
    schedule.to_ical.should == expectation
  end

  it 'should not modify the duration when running to_ical' do
    schedule = IceCube::Schedule.new(Time.now, :duration => 3600)
    schedule.to_ical
    schedule.duration.should == 3600
  end

  it 'should default to to_ical using local time' do
    time = Time.now
    schedule = IceCube::Schedule.new(Time.now)
    schedule.to_ical.should == "DTSTART;TZID=#{time.zone}:#{time.strftime('%Y%m%dT%H%M%S')}" # default false
  end

  it 'should not have an rtime that duplicates start time' do
    start = Time.utc(2012, 12, 12, 12, 0, 0)
    schedule = IceCube::Schedule.new(start)
    schedule.add_recurrence_time start
    schedule.to_ical.should == "DTSTART:20121212T120000Z"
  end

  it 'should be able to receive a to_ical in utc time' do
    time = Time.now
    schedule = IceCube::Schedule.new(Time.now)
    schedule.to_ical.should == "DTSTART;TZID=#{time.zone}:#{time.strftime('%Y%m%dT%H%M%S')}" # default false
    schedule.to_ical(false).should == "DTSTART;TZID=#{time.zone}:#{time.strftime('%Y%m%dT%H%M%S')}"
    schedule.to_ical(true).should  == "DTSTART:#{time.utc.strftime('%Y%m%dT%H%M%S')}Z"
  end

  it 'should be able to serialize to ical with an until date' do
    rule = IceCube::Rule.weekly.until Time.now
    rule.to_ical.should match /^FREQ=WEEKLY;UNTIL=\d{8}T\d{6}Z$/
  end

  it 'should be able to serialize to ical with a count date' do
    rule = IceCube::Rule.weekly.count(5)
    rule.to_ical.should match /^FREQ=WEEKLY;COUNT=5$/
  end

  %w{secondly minutely hourly daily monthly yearly}.each do |mthd|
    it "should include intervals for #{mthd} rule" do
      interval = 2
      rule = IceCube::Rule.send(mthd.to_sym, interval)
      rule.to_ical.should == "FREQ=#{mthd.upcase};INTERVAL=#{interval}"
    end
  end

  it 'should include intervals for weekly rule, including weekstart' do
    interval = 2
    rule = IceCube::Rule.send(:weekly, interval)
    rule.to_ical.should == "FREQ=WEEKLY;INTERVAL=#{interval};WKST=SU"
  end

  it 'should include intervals for weekly rule, including custom weekstart' do
    interval = 2
    rule = IceCube::Rule.send(:weekly, interval, :monday)
    rule.to_ical.should == "FREQ=WEEKLY;INTERVAL=#{interval};WKST=MO"
  end

  it 'should not repeat interval when updating rule' do
    rule = IceCube::Rule.weekly
    rule.interval(2)
    rule.to_ical.should =~ /^FREQ=WEEKLY;INTERVAL=2/
  end

end
