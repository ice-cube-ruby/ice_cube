require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'to_s' do

  it 'should have a useful base to_s representation for a secondly rule' do
    Rule.secondly.to_s.should == 'Secondly'
    Rule.secondly(2).to_s.should == 'Every 2 seconds'
  end
  
  it 'should have a useful base to_s representation for a minutely rule' do
    Rule.minutely.to_s.should == 'Minutely'
    Rule.minutely(2).to_s.should == 'Every 2 minutes'
  end
  
  it 'should have a useful base to_s representation for a hourly rule' do
    Rule.hourly.to_s.should == 'Hourly'
    Rule.hourly(2).to_s.should == 'Every 2 hours'
  end
  
  it 'should have a useful base to_s representation for a daily rule' do
    Rule.daily.to_s.should == 'Daily'
    Rule.daily(2).to_s.should == 'Every 2 days'
  end
  
  it 'should have a useful base to_s representation for a weekly rule' do
    Rule.weekly.to_s.should == 'Weekly'
    Rule.weekly(2).to_s.should == 'Every 2 weeks'
  end
  
  it 'should have a useful base to_s representation for a monthly rule' do
    Rule.monthly.to_s.should == 'Monthly'
    Rule.monthly(2).to_s.should == 'Every 2 months'
  end
  
  it 'should have a useful base to_s representation for a yearly rule' do
    Rule.yearly.to_s.should == 'Yearly'
    Rule.yearly(2).to_s.should == 'Every 2 years'
  end
  
  it 'should work with various sentence types properly' do
    Rule.weekly.to_s.should == 'Weekly'
    Rule.weekly.day(:monday).to_s.should == 'Weekly on Mondays'
    Rule.weekly.day(:monday, :tuesday).to_s.should == 'Weekly on Mondays and Tuesdays'
    Rule.weekly.day(:monday, :tuesday, :wednesday).to_s.should == 'Weekly on Mondays, Tuesdays, and Wednesdays'
  end

end