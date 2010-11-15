require File.dirname(__FILE__) + '/spec_helper'

include IceCube

describe Schedule, :remaining_occurrences do

  it 'should get the proper remaining occurrences from now' do
    schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.remaining_occurrences.size.should == 23 - schedule.start_time.hour
  end

  it 'should get the proper ramining occurrences past the end of the year' do
    schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.remaining_occurrences(schedule.end_time + 1.year).size.should == 0
  end

end
  
describe Schedule, :next_occurrence do

  it 'should get the next occurrence from now' do
    schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.next_occurrence.should == schedule.start_time + 1.hour
  end

  it 'should get the next occurrence past the end of the year' do
    schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.next_occurrence(schedule.end_time + 1.year).should == nil
  end

  it 'should be able to use next_occurrence on a never-ending schedule' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrence(schedule.start_time).should == schedule.start_time + 1.hour
  end

  it 'should get the next occurrence when a recurrence date is also added' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_date(schedule.start_time + 30.minutes)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrence(schedule.start_time).should == schedule.start_time + 30.minutes
  end

  it 'should get the next occurrence and ignore recurrence dates that are before the desired time' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_date(schedule.start_time + 30.minutes)
    schedule.add_recurrence_date(schedule.start_time - 30.minutes)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrence(schedule.start_time).should == schedule.start_time + 30.minutes
  end

end

describe Schedule, :next_occurrences do

  it 'should get the next 3 occurrence from now' do
    schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.next_occurrences(3).should == [schedule.start_time + 1.hour,
      schedule.start_time + 2.hours,
      schedule.start_time + 3.hours]
  end

  it 'should get the next 3 occurrence past the end of the year' do
    schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
    schedule.add_recurrence_rule(Rule.hourly)
    schedule.next_occurrences(3, schedule.end_time + 1.year).should == []
  end

  it 'should be able to use next_occurrences on a never-ending schedule' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrences(3, schedule.start_time).should == [schedule.start_time + 1.hour,
      schedule.start_time + 2.hours,
      schedule.start_time + 3.hours]
  end

  it 'should get the next 3 occurrences when a recurrence date is also added' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.hourly
    schedule.add_recurrence_date(schedule.start_time + 30.minutes)
    schedule.next_occurrences(3, schedule.start_time).should == [schedule.start_time + 30.minutes,
      schedule.start_time + 1.hours,
      schedule.start_time + 2.hours]
  end

  it 'should get the next 3 occurrences and ignore recurrence dates that are before the desired time' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_date(schedule.start_time + 30.minutes)
    schedule.add_recurrence_date(schedule.start_time - 30.minutes)
    schedule.add_recurrence_rule Rule.hourly
    schedule.next_occurrences(3, schedule.start_time).should == [schedule.start_time + 30.minutes,
      schedule.start_time + 1.hours,
      schedule.start_time + 2.hours]
  end

end
