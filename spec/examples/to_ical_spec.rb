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
  
end
