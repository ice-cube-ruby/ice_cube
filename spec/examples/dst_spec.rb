require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'occurs_on?' do

  # DST in 2010 is March 14th at 2am
  it 'crosses a daylight savings time boundary with a recurrence rule in local time, by utc conversion' do
    start_date = Time.local(2010, 3, 13, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.count(20)
    dates = schedule.first(20)
    dates.size.should == 20
    #check assumptions
    dates.each do |date|
      date.utc?.should_not == true
      date.hour.should == 5
    end  
  end

  # DST in 2010 is November 7th at 2am
  it 'crosses a daylight savings time boundary (in the other direction) with a recurrence rule in local time, by utc conversion' do
    start_date = Time.local(2010, 11, 6, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.count(20)
    dates = schedule.first(20)
    dates.size.should == 20
    #check assumptions
    dates.each do |date|
      date.utc?.should_not == true
      date.hour.should == 5
    end  
  end
  
  it 'cross a daylight savings time boundary with a recurrence rule in local time' do
    start_date = Time.local(2010, 3, 14, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    # each occurrence MUST occur at 5pm, then we win
    dates = schedule.occurrences(start_date + 20 * IceCube::ONE_DAY)
    last = start_date
    dates.each do |date|
      date.hour.should == 5
      last = date
    end
  end

  it 'every two hours over a daylight savings time boundary, checking interval' do
    start_date = Time.local(2010, 11, 6, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.hourly(2)
    dates = schedule.first(100)
    #check assumption
    distance_in_hours = 0
    dates.each do |d|
      d.should == start_date + IceCube::ONE_HOUR * distance_in_hours
      distance_in_hours += 2
    end
  end
  
  it 'every 30 minutes over a daylight savings time boundary, checking interval' do
    start_date = Time.local(2010, 11, 6, 23, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.minutely(30)
    dates = schedule.first(100)
    #check assumption
    distance_in_minutes = 0
    dates.each do |d|
      d.should == start_date + IceCube::ONE_MINUTE * distance_in_minutes
      distance_in_minutes += 30
    end
  end
  
  it 'every 120 seconds over a daylight savings time boundary, checking interval' do
    start_date = Time.local(2010, 11, 6, 23, 50, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.secondly(120)
    dates = schedule.first(10)
    #check assumption
    distance_in_seconds = 0
    dates.each do |d|
      d.should == start_date + distance_in_seconds
      distance_in_seconds += 120
    end
  end
  
  it 'every other day over a daylight savings time boundary, checking hour/min/sec' do
    start_date = Time.local(2010, 11, 6, 20, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily(2)
    dates = schedule.first(10)
    #check assumption
    dates.each do |d|
      d.hour.should == start_date.hour
      d.min.should == start_date.min
      d.sec.should == start_date.sec
    end
  end
  
  it 'every other month over a daylight savings time boundary, checking day/hour/min/sec' do
    start_date = Time.local(2010, 11, 6, 20, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly(2)
    dates = schedule.first(10)
    #check assumption
    dates.each do |d|
      d.day.should == start_date.day
      d.hour.should == start_date.hour
      d.min.should == start_date.min
      d.sec.should == start_date.sec
    end
  end
  
  it 'every other year over a daylight savings time boundary, checking day/hour/min/sec' do
    start_date = Time.local(2010, 11, 6, 20, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly(2)
    dates = schedule.first(10)
    #check assumption
    dates.each do |d|
      d.month.should == start_date.month
      d.day.should == start_date.day
      d.hour.should == start_date.hour
      d.min.should == start_date.min
      d.sec.should == start_date.sec
    end
  end
  
  it 'LOCAL - has an until date on a rule that is over a DST from the start date' do
    start_date = Time.local(2010, 3, 13, 5, 0, 0)
    end_date = Time.local(2010, 3, 15, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.until(end_date)
    #make sure we end on the proper time
    schedule.all_occurrences.last.should == end_date
  end

  it 'UTC - has an until date on a rule that is over a DST from the start date' do
    start_date = Time.utc(2010, 3, 13, 5, 0, 0)
    end_date = Time.utc(2010, 3, 15, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.until(end_date)
    #make sure we end on the proper time
    schedule.all_occurrences.last.should == end_date
  end

  it 'LOCAL - has an until date on a rule that is over a DST from the start date (other direction)' do
    start_date = Time.local(2010, 11, 5, 5, 0, 0)
    end_date = Time.local(2010, 11, 10, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.until(end_date)
    #make sure we end on the proper time
    schedule.all_occurrences.last.should == end_date
  end

  it 'UTC - has an until date on a rule that is over a DST from the start date (other direction)' do
    start_date = Time.utc(2010, 11, 5, 5, 0, 0)
    end_date = Time.utc(2010, 11, 10, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily.until(end_date)
    #make sure we end on the proper time
    schedule.all_occurrences.last.should == end_date
  end
  
  it 'LOCAL - has an end date on a rule that is over a DST from the start date' do
    start_date = Time.local(2010, 3, 13, 5, 0, 0)
    end_date = Time.local(2010, 3, 15, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    #make sure we end on the proper time
    schedule.occurrences(end_date).last.should == end_date
  end

  it 'UTC - has an end date on a rule that is over a DST from the start date' do
    start_date = Time.utc(2010, 3, 13, 5, 0, 0)
    end_date = Time.utc(2010, 3, 15, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    #make sure we end on the proper time
    schedule.occurrences(end_date).last.should == end_date
  end

  it 'LOCAL - has an end date on a rule that is over a DST from the start date (other direction)' do
    start_date = Time.local(2010, 11, 5, 5, 0, 0)
    end_date = Time.local(2010, 11, 10, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    #make sure we end on the proper time
    schedule.occurrences(end_date).last.should == end_date
  end

  it 'UTC - has an end date on a rule that is over a DST from the start date (other direction)' do
    start_date = Time.utc(2010, 11, 5, 5, 0, 0)
    end_date = Time.utc(2010, 11, 10, 5, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily
    #make sure we end on the proper time
    schedule.occurrences(end_date).last.should == end_date
  end

  it 'local - should make dates on interval over dst - github issue 4' do
    start_date = Time.local(2010, 3, 12, 19, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily(3)
    schedule.first(3).should == [Time.local(2010, 3, 12, 19, 0, 0), Time.local(2010, 3, 15, 19, 0, 0), Time.local(2010, 3, 18, 19, 0, 0)]
  end

  it 'local - should make dates on monthly interval over dst - github issue 4' do
    start_date = Time.local(2010, 3, 12, 19, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly(2)
    schedule.first(3).should == [Time.local(2010, 3, 12, 19, 0, 0), Time.local(2010, 5, 12, 19, 0, 0), Time.local(2010, 7, 12, 19, 0, 0)]
  end

  it 'local - should make dates on yearly interval over dst - github issue 4' do
    start_date = Time.local(2010, 3, 12, 19, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.yearly(2)
    schedule.first(3).should == [Time.local(2010, 3, 12, 19, 0, 0), Time.local(2012, 3, 12, 19, 0, 0), Time.local(2014, 3, 12, 19, 0, 0)]
  end

  
end
