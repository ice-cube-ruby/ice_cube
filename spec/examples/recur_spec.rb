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

end
