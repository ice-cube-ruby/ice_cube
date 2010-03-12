require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'to_yaml' do

  it 'should respond to .to_yaml' do
    schedule = Schedule.new(Date.today)
    schedule.add_recurrence_rule Rule.daily.until(Date.today)
    #check assumption
    schedule.should respond_to('to_yaml')
  end

end

describe Schedule, 'occurs_on?' do
  
  it 'should respond to complex combinations (1)' do
    start_date = Date.civil(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly(2).day(:wednesday).month_of_year(:april)
    #check assumptions
    dates = schedule.occurrences(Date.civil(2011, 12, -1)) #two years
    dates.count.should == 4
    dates.each do |date|
      date.wday.should == 3
      date.month.should == 4
      date.year.should == start_date.year #since we're doing every other
    end
  end
  
  it 'should respond to a single date event' do
    schedule = Schedule.new(Date.today)
    schedule.add_recurrence_date(Date.today + 2)
    #check assumptions
    dates = schedule.occurrences(Date.today + 50)
    dates.count.should == 1
    dates[0].should == (Date.today + 2)
  end

  it 'should not return anything when given a single date and the same exclusion date' do
    schedule = Schedule.new(Date.today)
    schedule.add_recurrence_date(Date.today + 2)
    schedule.add_exception_date(Date.today + 2)
    #check assumption
    schedule.occurrences(Date.today + 50).count.should == 0
  end

  it 'should return properly with a combination of a recurrence and exception rule' do
    schedule = Schedule.new(Date.today)
    schedule.add_recurrence_rule Rule.daily # every day
    schedule.add_exception_rule Rule.weekly.day(:monday, :tuesday, :wednesday) # except these
    #check assumption - in 2 weeks, we should have 8 days
    schedule.occurrences(Date.today + 13).count.should == 8
  end

  it 'should be able to exclude a certain date from a range' do
    schedule = Schedule.new(Date.today)
    schedule.add_recurrence_rule Rule.daily
    schedule.add_exception_date(Date.today + 1) # all days except tomorrow
    # check assumption
    dates = schedule.occurrences(Date.today + 13) # 2 weeks
    dates.count.should == 13 # 2 weeks minus 1 day
    dates.should_not include(Date.today + 1)
  end

end
