require File.dirname(__FILE__) + '/spec_helper'

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
    schedule.occurrences(start_date + 50 * IceCube::ONE_DAY).count.should == 0
  end

  it 'should return properly with a combination of a recurrence and exception rule' do
    schedule = Schedule.new(DAY)
    schedule.add_recurrence_rule Rule.daily # every day
    schedule.add_exception_rule Rule.weekly.day(:monday, :tuesday, :wednesday) # except these
    #check assumption - in 2 weeks, we should have 8 days
    schedule.occurrences(DAY + 13 * IceCube::ONE_DAY).count.should == 8
  end

  it 'should be able to exclude a certain date from a range' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    schedule.add_exception_date(start_date + 1 * IceCube::ONE_DAY) # all days except tomorrow
    # check assumption
    dates = schedule.occurrences(start_date + 13 * IceCube::ONE_DAY) # 2 weeks
    dates.count.should == 13 # 2 weeks minus 1 day
    dates.should_not include(start_date + 1 * IceCube::ONE_DAY)
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
    start_date = WEDNESDAY + IceCube::ONE_DAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.day(:thursday).count(5)
    dates = schedule.all_occurrences
    dates.uniq.count.should == 5
    dates.each { |d| d.wday == 4 }
    dates.should include(WEDNESDAY + IceCube::ONE_DAY)
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

  it 'will only return count# if you specify a count and use .first' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.count(10)
    dates = schedule.first(200)
    dates.count.should == 10
  end

  it 'occurs yearly' do
    start_date = DAY
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly
    dates = schedule.first(10)
    dates.each do |date|
      date.month.should == start_date.month
      date.day.should == start_date.day
      date.hour.should == start_date.hour
      date.min.should == start_date.min
      date.sec.should == start_date.sec
    end
  end

  it 'occurs monthly' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly
    dates = schedule.first(10)
    dates.each do |date|
      date.day.should == start_date.day
      date.hour.should == start_date.hour
      date.min.should == start_date.min
      date.sec.should == start_date.sec
    end
  end
  
  it 'occurs daily' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    dates = schedule.first(10)
    dates.each do |date|
      date.hour.should == start_date.hour
      date.min.should == start_date.min
      date.sec.should == start_date.sec
    end
  end
  
  it 'occurs hourly' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.hourly
    dates = schedule.first(10)
    dates.each do |date|
      date.min.should == start_date.min
      date.sec.should == start_date.sec
    end
  end
  
  it 'occurs minutely' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.minutely
    dates = schedule.first(10)
    dates.each do |date|
      date.sec.should == start_date.sec
    end
  end

  it 'occurs every second for an hour' do
    start_date = Time.now
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.secondly.count(60)
    # build the expectation list
    expectation = []
    0.upto(59) { |i| expectation << start_date + i }
    # compare with what we get
    dates = schedule.all_occurrences
    dates.count.should == 60
    schedule.all_occurrences.should == expectation
  end

  it 'perform a every day LOCAL and make sure we get back LOCAL' do
    start_date = Time.local(2010, 9, 2, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    schedule.first(10).each do |d| 
      d.utc?.should == false
      d.hour.should == 5
      (d.utc_offset == -5 * ONE_HOUR || d.utc_offset == -4 * ONE_HOUR).should be true
    end
  end

  it 'perform a every day LOCAL and make sure we get back LOCAL' do
    start_date = Time.utc(2010, 9, 2, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    schedule.first(10).each do |d| 
      d.utc?.should == true
      d.utc_offset.should == 0
      d.hour.should == 5
    end    
  end
  
  # here we purposely put a UTC time that is before the range ends, to
  # verify ice_cube is properly checking until bounds
  it 'works with a until date that is UTC, but the start date is local' do
    start_date = Time.local(2010, 11, 6, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.until(Time.utc(2010, 11, 10, 8, 0, 0)) #4 o clocal local
    #check assumptions
    dates = schedule.all_occurrences
    dates.each { |d| d.utc?.should == false }
    dates.should == [Time.local(2010, 11, 6, 5, 0, 0), 
      Time.local(2010, 11, 7, 5, 0, 0), Time.local(2010, 11, 8, 5, 0, 0), 
      Time.local(2010, 11, 9, 5, 0, 0)]
  end

  # here we purposely put a local time that is before the range ends, to
  # verify ice_cube is properly checking until bounds
  it 'works with a until date that is local, but the start date is UTC' do
    start_date = Time.utc(2010, 11, 6, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.until(Time.local(2010, 11, 9, 23, 0, 0)) #4 o UTC time
    #check assumptions
    dates = schedule.all_occurrences
    dates.each { |d| d.utc?.should == true }
    dates.should == [Time.utc(2010, 11, 6, 5, 0, 0), 
      Time.utc(2010, 11, 7, 5, 0, 0), Time.utc(2010, 11, 8, 5, 0, 0), 
      Time.utc(2010, 11, 9, 5, 0, 0)]
  end

  it 'works with a monthly rule iterating on UTC' do
    start_date = Time.utc(2010, 4, 24, 15, 45, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly
    dates = schedule.first(10)
    dates.each do |d|
      d.day.should == 24
      d.hour.should == 15
      d.min.should == 45
      d.sec.should == 0
      d.utc?.should be true
    end
  end

  it 'can retrieve rrules from a schedule' do
    schedule = Schedule.new(Time.now)
    rules = [Rule.daily, Rule.monthly, Rule.yearly]
    rules.each { |r| schedule.add_recurrence_rule(r) }
    # pull the rules back out of the schedule and compare
    schedule.rrules.should == rules
  end

  it 'can retrieve exrules from a schedule' do
    schedule = Schedule.new(Time.now)
    rules = [Rule.daily, Rule.monthly, Rule.yearly]
    rules.each { |r| schedule.add_exception_rule(r) }
    # pull the rules back out of the schedule and compare
    schedule.exrules.should == rules
  end

  it 'can retrieve rdates from a schedule' do
    schedule = Schedule.new(Time.now)
    dates = [Time.now, Time.now + 5, Time.now + 10]
    dates.each { |d| schedule.add_recurrence_date(d) }
    # pull the dates back out of the schedule and compare
    schedule.rdates.should == dates
  end
  
  it 'can retrieve exdates from a schedule' do
    schedule = Schedule.new(Time.now)
    dates = [Time.now, Time.now + 5, Time.now + 10]
    dates.each { |d| schedule.add_exception_date(d) }
    # pull the dates back out of the schedule and compare
    schedule.exdates.should == dates
  end

  it 'can reuse the same rule' do
    schedule = Schedule.new(Time.now)
    rule = Rule.daily
    schedule.add_recurrence_rule rule
    result1 = schedule.first(10)
    rule.day(:monday)
    # check to make sure the change affected the rule
    schedule.first(10).should_not == result1
  end

  it 'ensures that month of year (3) is march' do
    schedule = Schedule.new(DAY)
    schedule.add_recurrence_rule Rule.daily.month_of_year(:march)
    
    schedule2 = Schedule.new(DAY)
    schedule2.add_recurrence_rule Rule.daily.month_of_year(3)
    
    schedule.first(10).should == schedule2.first(10)
  end

  it 'ensures that day of week (1) is monday' do
    schedule = Schedule.new(DAY)
    schedule.add_recurrence_rule Rule.daily.day(:monday)
    
    schedule2 = Schedule.new(DAY)
    schedule2.add_recurrence_rule Rule.daily.day(1)
    
    schedule.first(10).should == schedule2.first(10)
  end

  it 'should be able to find occurrences between two dates which are both in the future' do
    start_time = Time.now
    schedule = Schedule.new(start_time)
    schedule.add_recurrence_rule Rule.daily
    dates = schedule.occurrences_between(start_time + ONE_DAY * 2, start_time + ONE_DAY * 4)
    dates.should == [start_time + ONE_DAY * 2, start_time + ONE_DAY * 3, start_time + ONE_DAY * 4]
  end

  it 'should be able to determine whether a given rule falls on a Date (rather than a time) - happy path' do
    start_time = Time.local(2010, 7, 2, 10, 0, 0)
    schedule = Schedule.new(start_time)
    schedule.add_recurrence_rule Rule.daily.count(10)
    schedule.occurs_on?(Date.new(2010, 7, 4)).should be true
  end
  
  it 'should be able to determine whether a given rule falls on a Date (rather than a time)' do
    start_time = Time.local(2010, 7, 2, 10, 0, 0)
    schedule = Schedule.new(start_time)
    schedule.add_recurrence_rule Rule.daily.count(10)
    schedule.occurs_on?(Date.new(2010, 7, 1)).should_not be true
  end

  it 'should be able to get back rdates from an ice_cube schedule' do
    schedule = Schedule.new DAY
    schedule.add_recurrence_date DAY
    schedule.add_recurrence_date(DAY + 2)
    schedule.rdates.should == [DAY, DAY + 2]
  end

  it 'should be able to get back exdates from an ice_cube schedule' do
    schedule = Schedule.new DAY
    schedule.add_exception_date DAY
    schedule.add_exception_date(DAY + 2)
    schedule.exdates.should == [DAY, DAY + 2]
  end

  it 'occurs_on? works for a single date recurrence' do
    schedule = Schedule.new Time.utc(2009, 9, 2, 13, 0, 0)
    schedule.add_recurrence_date Time.utc(2009, 9, 2, 13, 0, 0)
    schedule.occurs_on?(Date.new(2009, 9, 2)).should be true
    schedule.occurs_on?(Date.new(2009, 9, 1)).should_not be true
    schedule.occurs_on?(Date.new(2009, 9, 3)).should_not be true
  end

  it 'occurs_on? should only be true for the single day of a certain event' do
    Time.zone = "Pacific Time (US & Canada)"
    schedule = Schedule.new Time.zone.parse("2010/5/13 02:00:00")
    schedule.add_recurrence_date Time.zone.parse("2010/5/13 02:00:00")
    schedule.occurs_on?(Date.new(2010, 5, 13)).should be true
    schedule.occurs_on?(Date.new(2010, 5, 14)).should_not be true
    schedule.occurs_on?(Date.new(2010, 5, 15)).should_not be true
  end
  
end
