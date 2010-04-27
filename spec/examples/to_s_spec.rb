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

  it 'should work with a single date' do
    schedule = Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.to_s.should == "March 20, 2010"
  end
  
  it 'should work with additional dates' do
    schedule = Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 21)
    schedule.to_s.should == 'March 20, 2010 / March 21, 2010'
  end

  it 'should work with rules and dates' do
    schedule = Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_rule Rule.weekly
    schedule.to_s.should == 'March 20, 2010 / Weekly'
  end

  it 'should work with rules and dates and exdates' do
    schedule = Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule Rule.weekly
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_exception_date Time.local(2010, 3, 20) # ignored
    schedule.add_exception_date Time.local(2010, 3, 21)
    schedule.to_s.should == 'Weekly / not on March 20, 2010 / not on March 21, 2010'
  end
  
end
