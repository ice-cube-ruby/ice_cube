require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'to_yaml' do

  it 'should respond to .to_yaml' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.daily.until(Time.now)
    #check assumption
    schedule.should respond_to('to_yaml')
  end
  
  it 'should be able to make a round-trip to YAML' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.daily.until(Time.now + 10)
    result1 = schedule.all_occurrences
    
    yaml_string = schedule.to_yaml
    
    schedule2 = Schedule.from_yaml(yaml_string)
    result2 = schedule.all_occurrences
    
    #make sure they both have the same result
    result1.should == result2
  end

end

describe Schedule, 'occurs_on?' do
  
  it 'should respond to complex combinations (1)' do
    start_date = Time.utc(2010, 1, 1)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly(2).day(:wednesday).month_of_year(:april)
    #check assumptions
    dates = schedule.occurrences(Time.utc(2011, 12, 31)) #two years
    dates.count.should == 4
    dates.each do |date|
      date.wday.should == 3
      date.month.should == 4
      date.year.should == start_date.year #since we're doing every other
    end
  end
  
  it 'should respond to a single date event' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_date(start_date + 2)
    #check assumptions
    dates = schedule.occurrences(start_date + 50)
    dates.count.should == 1
    dates[0].should == start_date + 2
  end

  it 'should not return anything when given a single date and the same exclusion date' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_date(start_date + 2)
    schedule.add_exception_date(start_date + 2)
    #check assumption
    schedule.occurrences(start_date + 50 * ONE_DAY).count.should == 0
  end

  it 'should return properly with a combination of a recurrence and exception rule' do
    schedule = Schedule.new(DAY)
    schedule.add_recurrence_rule Rule.daily # every day
    schedule.add_exception_rule Rule.weekly.day(:monday, :tuesday, :wednesday) # except these
    #check assumption - in 2 weeks, we should have 8 days
    schedule.occurrences(DAY + 13 * ONE_DAY).count.should == 8
  end

  it 'should be able to exclude a certain date from a range' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    schedule.add_exception_date(start_date + 1 * ONE_DAY) # all days except tomorrow
    # check assumption
    dates = schedule.occurrences(start_date + 13 * ONE_DAY) # 2 weeks
    dates.count.should == 13 # 2 weeks minus 1 day
    dates.should_not include(start_date + 1 * ONE_DAY)
  end

  it 'make a schedule with a start_date not included in a rule, and make sure that count behaves properly' do
    start_date = WEDNESDAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.day(:thursday).count(5)
    dates = schedule.all_occurrences
    dates.uniq.count.should == 5
    dates.each { |d| d.wday == 4 }
    dates.should_not include(WEDNESDAY)
  end

  it 'make a schedule with a start_date included in a rule, and make sure that count behaves properly' do
    start_date = WEDNESDAY + ONE_DAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.day(:thursday).count(5)
    dates = schedule.all_occurrences
    dates.uniq.count.should == 5
    dates.each { |d| d.wday == 4 }
    dates.should include(WEDNESDAY + ONE_DAY)
  end

  it 'should work as expected with a second_of_minute rule specified' do
    start_date = DAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.second_of_minute(30)
    dates = schedule.occurrences(start_date + 30 * 60)
    dates.each { |date| date.sec == 30 }
  end

  it 'ensure that when count on a rule is set to 0, 0 occurrences come back' do
    start_date = DAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.count(0)
    schedule.all_occurrences.should == []
  end

  it 'cross a daylight savings time boundary with a recurrence rule in local time' do
    start_date = Time.local(2010, 3, 14, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    # each occurrence MUST occur at 5pm, then we win
    dates = schedule.occurrences(start_date + 20 * ONE_DAY)
    last = start_date
    dates.each do |date|
      date.hour.should == 5
      last = date
    end
  end

  it 'should be able to be schedules at 1:st:st and 2:st:st every day' do
    start_date = Time.utc(2007, 9, 2, 9, 15, 25)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.hour_of_day(1, 2).count(6)
    dates = schedule.all_occurrences
    dates.should == [Time.utc(2007, 9, 3, 1, 15, 25), Time.utc(2007, 9, 3, 2, 15, 25),
                     Time.utc(2007, 9, 4, 1, 15, 25), Time.utc(2007, 9, 4, 2, 15, 25), 
                     Time.utc(2007, 9, 5, 1, 15, 25), Time.utc(2007, 9, 5, 2, 15, 25)]
  end

  it 'should be able to be schedules at 1:0:st and 2:0:st every day' do
    start_date = Time.utc(2007, 9, 2, 9, 15, 25)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.hour_of_day(1, 2).minute_of_hour(0).count(6)
    dates = schedule.all_occurrences
    dates.should == [Time.utc(2007, 9, 3, 1, 0, 25), Time.utc(2007, 9, 3, 2, 0, 25),
                     Time.utc(2007, 9, 4, 1, 0, 25), Time.utc(2007, 9, 4, 2, 0, 25), 
                     Time.utc(2007, 9, 5, 1, 0, 25), Time.utc(2007, 9, 5, 2, 0, 25)]
  end

  # DST in 2010 is March 14th at 2am
  it 'crosses a daylight savings time boundary with a recurrence rule in local time, by utc conversion' do
    start_date = Time.local(2010, 3, 13, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.count(20)
    dates = schedule.first(20)
    dates.count.should == 20
    #check assumptions
    dates.each do |date|
      date.hour.should == 5
    end  
  end

  # DST in 2010 is November 7th at 2am
  it 'crosses a daylight savings time boundary (in the other direction) with a recurrence rule in local time, by utc conversion' do
    start_date = Time.local(2010, 11, 6, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.count(20)
    dates = schedule.first(20)
    dates.count.should == 20
    #check assumptions
    dates.each do |date|
      date.hour.should == 5
    end  
  end

end
