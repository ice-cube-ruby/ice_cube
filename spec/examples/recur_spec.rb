require File.dirname(__FILE__) + '/../spec_helper'

include IceCube

describe :remaining_occurrences do

  it 'should get the proper remaining occurrences from now' do
    start_time = Time.now
    end_time = Time.local(start_time.year, start_time.month, start_time.day, 23, 59, 59)
    schedule = Schedule.new(start_time)
    schedule.add_recurrence_rule(Rule.hourly.until(end_time))
    schedule.remaining_occurrences(start_time).size.should == 24 - schedule.start_time.hour
  end

  it 'should get the proper ramining occurrences past the end of the year' do
    start_time = Time.now
    schedule = Schedule.new(start_time)
    schedule.add_recurrence_rule(Rule.hourly.until(start_time + ONE_DAY))
    schedule.remaining_occurrences(start_time + 366 * ONE_DAY).size.should == 0
  end

end

describe :occurring_between? do

  let(:start_time) { Time.local(2012, 7, 7, 7) }
  let(:schedule) do
    IceCube::Schedule.new(start_time, :duration => 30).tap do |schedule|
      schedule.rrule IceCube::Rule.daily
    end
  end

  it 'should occur when the range is entirely contained' do
    schedule.occurring_between?(start_time + 1, start_time + 20).should be_true
  end

  it 'should occur when the range is offset left' do
    schedule.occurring_between?(start_time - 60, start_time - 29).should be_true
  end

  it 'should occur when the range is offset right' do
    schedule.occurring_between?(start_time + 29, start_time + 40).should be_true
  end

  it 'should occur when the range is overflowing' do
    schedule.occurring_between?(start_time - 29, start_time + 40).should be_true
  end

  it 'should be false when the range starts after the duration expires' do
    schedule.occurring_between?(start_time + 30, start_time + 40).should be_false
  end

  it 'should be false when the range ends before the start' do
    schedule.occurring_between?(start_time - 40, start_time - 30).should be_false
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
    schedule.next_occurrence(schedule.end_time + 366 * ONE_DAY).should == schedule.end_time + 366 * ONE_DAY + 1 * ONE_HOUR
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
    schedule.add_recurrence_rule(Rule.hourly.until(Time.now + 365 * ONE_DAY))
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

  it 'should generate the same comparable time objects (down to millisecond) on two runs' do
    schedule = Schedule.new Time.now
    schedule.rrule Rule.daily
    schedule.next_occurrences(5).should == schedule.next_occurrences(5)
  end

end
