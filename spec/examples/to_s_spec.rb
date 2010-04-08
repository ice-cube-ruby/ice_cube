require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'to_s' do

  it 'should have a useful base to_s representation for a secondly rule' do
    Rule.secondly.to_s.should == 'Every second'
    Rule.secondly(2).to_s.should == 'Every 2 seconds'
  end
  
  it 'should have a useful base to_s representation for a minutely rule' do
    Rule.minutely.to_s.should == 'Every minute'
    Rule.minutely(2).to_s.should == 'Every 2 minutes'
  end
  
  it 'should have a useful base to_s representation for a hourly rule' do
    Rule.hourly.to_s.should == 'Every hour'
    Rule.hourly(2).to_s.should == 'Every 2 hours'
  end
  
  it 'should have a useful base to_s representation for a daily rule' do
    Rule.daily.to_s.should == 'Every day'
    Rule.daily(2).to_s.should == 'Every 2 days'
  end
  
  it 'should have a useful base to_s representation for a weekly rule' do
    Rule.weekly.to_s.should == 'Every week'
    Rule.weekly(2).to_s.should == 'Every 2 weeks'
  end
  
  it 'should have a useful base to_s representation for a monthly rule' do
    Rule.monthly.to_s.should == 'Every month'
    Rule.monthly(2).to_s.should == 'Every 2 months'
  end
  
  it 'should have a useful base to_s representation for a yearly rule' do
    Rule.yearly.to_s.should == 'Every year'
    Rule.yearly(2).to_s.should == 'Every 2 years'
  end

end