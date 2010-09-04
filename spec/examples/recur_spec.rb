require File.dirname(__FILE__) + '/spec_helper'

include IceCube

describe Schedule, 'remaining_occurrences from now' do
  schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
  schedule.add_recurrence_rule(Rule.hourly)
  schedule.remaining_occurrences.size.should == 23 - schedule.start_time.hour
end

describe Schedule, 'remaining_occurrences past end' do
  schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
  schedule.add_recurrence_rule(Rule.hourly)
  schedule.remaining_occurrences(schedule.end_time + 1.year).size.should == 0
end

describe Schedule, 'next_occurrence from now' do
  schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
  schedule.add_recurrence_rule(Rule.hourly)
  schedule.next_occurrence.should == schedule.start_time + 1.hour
end

describe Schedule, 'next_occurrence past end' do
  schedule = Schedule.new(Time.now, :end_time => Time.now.end_of_day)
  schedule.add_recurrence_rule(Rule.hourly)
  schedule.next_occurrence(schedule.end_time + 1.year).should == nil
end
