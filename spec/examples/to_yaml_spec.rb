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
    result2 = schedule2.all_occurrences
    
    #make sure they both have the same result
    result1.should == result2
  end

  it 'should be able to make a round-trip to YAML with .day' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.daily.day(:monday, :wednesday).until(Time.now + 10)
    result1 = schedule.all_occurrences
    
    yaml_string = schedule.to_yaml
    
    schedule2 = Schedule.from_yaml(yaml_string)
    result2 = schedule2.all_occurrences
    
    #make sure they both have the same result
    result1.should == result2
  end


end