require File.dirname(__FILE__) + '/../spec_helper'

include IceCube

describe :remaining_occurrences do

  it 'should get the proper remaining occurrences from now' do
    start_time = Time.now
    schedule = Schedule.new(start_time, :end_time => Time.local(start_time.year, start_time.month, start_time.day, 23, 59, 59))
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.remaining_occurrences(start_time).size.should == 24 - schedule.start_time.hour
  end

  it 'should get the proper ramining occurrences past the end of the year' do
    start_time = Time.now
    schedule = Schedule.new(start_time, :end_time => start_time + ONE_DAY)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.remaining_occurrences(schedule.end_time + 366 * ONE_DAY).size.should == 0
  end

end
  
describe :next_occurrence do

  it 'should get the next occurrence from now' do
    start_time = Time.local(2010, 10, 10, 10, 0, 0)
    schedule = Schedule.new(start_time, :end_time => start_time + 24 * ONE_HOUR)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.next_occurrence(schedule.start_time).should == schedule.start_time + 1 * ONE_HOUR
  end

  it 'should get the next occurrence past the end of the year' do
    schedule = Schedule.new(Time.now, :end_time => Time.now + 24 * ONE_HOUR)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.next_occurrence(schedule.end_time + 366 * ONE_DAY).should == nil
  end

  it 'should be able to use next_occurrence on a never-ending schedule' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrence(schedule.start_time).should == schedule.start_time + ONE_HOUR
  end

  it 'should get the next occurrence when a recurrence date is also added' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_date(schedule.start_time + 30 * ONE_MINUTE)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrence(schedule.start_time).should == schedule.start_time + 30 * ONE_MINUTE
  end

  it 'should get the next occurrence and ignore recurrence dates that are before the desired time' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_date(schedule.start_time + 30 * ONE_MINUTE)
    schedule.add_recurrence_date(schedule.start_time - 30 * ONE_MINUTE)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrence(schedule.start_time).should == schedule.start_time + 30 * ONE_MINUTE
  end

end

describe :next_occurrences do

  it 'should get the next 3 occurrence from now' do
    start_time = Time.local(2010, 1, 1, 10, 0, 0)
    schedule = Schedule.new(start_time, :end_time => start_time + ONE_HOUR * 24)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.next_occurrences(3, start_time).should == [
      schedule.start_time + 1 * ONE_HOUR,
      schedule.start_time + 2 * ONE_HOUR,
      schedule.start_time + 3 * ONE_HOUR]
  end

  it 'should get the next 3 occurrence past the end of the year' do
    schedule = Schedule.new(Time.now, :end_time => Time.now + ONE_HOUR * 24)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.next_occurrences(3, schedule.end_time + 366 * ONE_DAY).should == []
  end

  it 'should be able to use next_occurrences on a never-ending schedule' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrences(3, schedule.start_time).should == [
      schedule.start_time + 1 * ONE_HOUR,
      schedule.start_time + 2 * ONE_HOUR,
      schedule.start_time + 3 * ONE_HOUR]
  end

  it 'should get the next 3 occurrences when a recurrence date is also added' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.hourly
    schedule.add_recurrence_date(schedule.start_time + 30 * ONE_MINUTE)
    schedule.next_occurrences(3, schedule.start_time).should == [
      schedule.start_time + 30 * ONE_MINUTE,
      schedule.start_time + 1 * ONE_HOUR,
      schedule.start_time + 2 * ONE_HOUR]
  end

  it 'should get the next 3 occurrences and ignore recurrence dates that are before the desired time' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_date(schedule.start_time + 30 * ONE_MINUTE)
    schedule.add_recurrence_date(schedule.start_time - 30 * ONE_MINUTE)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrences(3, schedule.start_time).should == [
      schedule.start_time + 30 * ONE_MINUTE,
      schedule.start_time + ONE_HOUR,
      schedule.start_time + ONE_HOUR * 2]
  end

end
