require 'ice_cube.rb'
include IceCube

describe Schedule, 'to_yaml' do

  it 'should respond to .to_yaml' do
    schedule = Schedule.new(Date.today)
    schedule.add_recurrence_rule Rule.daily.until(Date.today)
    #check assumption
    schedule.should respond_to('to_yaml')
  end

end

describe Schedule, 'occurs_on?' do
  
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
    schedule.add_exception_rule Rule.weekly.day_of_week(:monday, :tuesday, :wednesday) # except these
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

  it 'should be able to handle a complex rule from the README' do
    schedule = Schedule.new(Date.civil(2010, 7, 13))
    schedule.add_recurrence_rule Rule.yearly
    schedule.add_recurrence_rule Rule.weekly.day_of_week(:sunday)
    #check assumption
    dates = schedule.occurrences(Date.civil(2030, 01, 01))
    dates.count.should > 0
    dates.each do |date|
      date.wday.should == 0
      date.mday.should == 13
    end
  end

  it 'should be able to handle a complex rule from the README with exceptions' do
    schedule = Schedule.new(Date.civil(2010, 01, 01))
    schedule.add_exception_rule Rule.weekly.day_of_week(:tuesday, :thursday)
    schedule.add_recurrence_rule Rule.daily
    #check assumptions
    dates = schedule.occurrences(Date.civil(2011, 01, 01))
    dates.count.should > 0
    dates.each do |date|
      date.wday.should_not == 2
      date.wday.should_not == 4
    end
  end
  
end
