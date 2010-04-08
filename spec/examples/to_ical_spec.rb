require File.dirname(__FILE__) + '/spec_helper'

describe IceCube, 'to_ical' do

  it 'should return a proper ical representation for a basic daily rule' do
    rule = Rule.daily
    rule.to_ical.should == "FREQ=DAILY"
  end

  it 'should return a proper ical representation for a basic monthly rule' do
    rule = Rule.weekly
    rule.to_ical.should == "FREQ=WEEKLY"
  end

  it 'should return a proper ical representation for a basic monthly rule' do
    rule = Rule.monthly
    rule.to_ical.should == "FREQ=MONTHLY"
  end

  it 'should return a proper ical representation for a basic yearly rule' do
    rule = Rule.yearly
    rule.to_ical.should == "FREQ=YEARLY"
  end

  it 'should return a proper ical representation for a basic hourly rule' do
    rule = Rule.hourly
    rule.to_ical.should == "FREQ=HOURLY"
  end

  it 'should return a proper ical representation for a basic minutely rule' do
    rule = Rule.minutely
    rule.to_ical.should == "FREQ=MINUTELY"
  end

  it 'should return a proper ical representation for a basic secondly rule' do
    rule = Rule.secondly
    rule.to_ical.should == "FREQ=SECONDLY"
  end
  
  it 'should be able to serialize a .day rule to_ical' do
    rule = Rule.daily.day(:monday, :tuesday)
    rule.to_ical.should == "FREQ=DAILY;BYDAY=MO,TU"
  end
  
  it 'should be able to serialize a .day_of_week rule to_ical' do
    rule = Rule.daily.day_of_week(:tuesday => [-1, -2])
    rule.to_ical.should == "FREQ=DAILY;BYDAY=-1TU,-2TU"
  end
  
  it 'should be able to serialize a .day_of_month rule to_ical' do
    rule = Rule.daily.day_of_month(23)
    rule.to_ical.should == "FREQ=DAILY;BYMONTHDAY=23"
  end
  
  it 'should be able to serialize a .day_of_year rule to_ical' do
    rule = Rule.daily.day_of_year(100,200)
    rule.to_ical.should == "FREQ=DAILY;BYYEARDAY=100,200"
  end
  
  it 'should be able to serialize a .month_of_year rule to_ical' do
    rule = Rule.daily.month_of_year(:january, :april)
    rule.to_ical.should == "FREQ=DAILY;BYMONTH=1,4"
  end
  
  it 'should be able to serialize a .hour_of_day rule to_ical' do
    rule = Rule.daily.hour_of_day(10, 20)
    rule.to_ical.should == "FREQ=DAILY;BYHOUR=10,20"
  end
  
  it 'should be able to serialize a .minute_of_hour rule to_ical' do
    rule = Rule.daily.minute_of_hour(5, 55)
    rule.to_ical.should == "FREQ=DAILY;BYMINUTE=5,55"
  end
  
  it 'should be able to serialize a .second_of_minute rule to_ical' do
    rule = Rule.daily.second_of_minute(0, 15, 30, 45)
    rule.to_ical.should == "FREQ=DAILY;BYSECOND=0,15,30,45"
  end
  
  it 'should be able to collapse a combination day_of_week and day' do
    rule = Rule.daily.day(:monday, :tuesday).day_of_week(:monday => [1, -1])
    rule.to_ical.should == "FREQ=DAILY;BYDAY=TU;BYDAY=1MO,-1MO"
  end
    
end
