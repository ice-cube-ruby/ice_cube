require File.dirname(__FILE__) + '/spec_helper'

describe IceCube::Schedule, 'to_s' do

  it 'should have a useful base to_s representation for a secondly rule' do
    IceCube::Rule.secondly.to_s.should == 'Secondly'
    IceCube::Rule.secondly(2).to_s.should == 'Every 2 seconds'
  end
  
  it 'should have a useful base to_s representation for a minutely rule' do
    IceCube::Rule.minutely.to_s.should == 'Minutely'
    IceCube::Rule.minutely(2).to_s.should == 'Every 2 minutes'
  end
  
  it 'should have a useful base to_s representation for a hourly rule' do
    IceCube::Rule.hourly.to_s.should == 'Hourly'
    IceCube::Rule.hourly(2).to_s.should == 'Every 2 hours'
  end
  
  it 'should have a useful base to_s representation for a daily rule' do
    IceCube::Rule.daily.to_s.should == 'Daily'
    IceCube::Rule.daily(2).to_s.should == 'Every 2 days'
  end
  
  it 'should have a useful base to_s representation for a weekly rule' do
    IceCube::Rule.weekly.to_s.should == 'Weekly'
    IceCube::Rule.weekly(2).to_s.should == 'Every 2 weeks'
  end
  
  it 'should have a useful base to_s representation for a monthly rule' do
    IceCube::Rule.monthly.to_s.should == 'Monthly'
    IceCube::Rule.monthly(2).to_s.should == 'Every 2 months'
  end
  
  it 'should have a useful base to_s representation for a yearly rule' do
    IceCube::Rule.yearly.to_s.should == 'Yearly'
    IceCube::Rule.yearly(2).to_s.should == 'Every 2 years'
  end
  
  it 'should work with various sentence types properly' do
    IceCube::Rule.weekly.to_s.should == 'Weekly'
    IceCube::Rule.weekly.day(:monday).to_s.should == 'Weekly on Mondays'
    IceCube::Rule.weekly.day(:monday, :tuesday).to_s.should == 'Weekly on Mondays and Tuesdays'
    IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s.should == 'Weekly on Mondays, Tuesdays, and Wednesdays'
  end

  it 'should work with a single date' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.to_s.should == "March 20, 2010"
  end
  
  it 'should work with additional dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 21)
    schedule.to_s.should == 'March 20, 2010 / March 21, 2010'
  end

  it 'should order dates that are out of order' do
    schedule = IceCube::Schedule.new Time.now
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 19)
    schedule.to_s.should == 'March 19, 2010 / March 20, 2010'
  end

  it 'should remove duplicate rdates' do
    schedule = IceCube::Schedule.new Time.now
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.to_s.should == 'March 20, 2010'
  end
  
  it 'should work with rules and dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.to_s.should == 'March 20, 2010 / Weekly'
  end

  it 'should work with rules and dates and exdates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.add_recurrence_date Time.local(2010, 3, 20)
    schedule.add_exception_date Time.local(2010, 3, 20) # ignored
    schedule.add_exception_date Time.local(2010, 3, 21)
    schedule.to_s.should == 'Weekly / not on March 20, 2010 / not on March 21, 2010'
  end

  it 'should work with a single rrule' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(:monday => [1])
    schedule.to_s.should == schedule.rrules[0].to_s
  end
  
end
