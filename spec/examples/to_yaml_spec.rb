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
    schedule.add_recurrence_rule Rule.daily.day(:monday, :wednesday)
    
    yaml_string = schedule.to_yaml
    schedule2 = Schedule.from_yaml(yaml_string)
    
    #make sure they both have the same result
    schedule.first(10).should == schedule2.first(10)
  end

  it 'should be able to make a round-trip to YAML with .day_of_month' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.monthly.day_of_month(10, 20)
    
    yaml_string = schedule.to_yaml
    schedule2 = Schedule.from_yaml(yaml_string)
    
    #make sure they both have the same result
    schedule.first(10).should == schedule2.first(10)
  end

  it 'should be able to make a round-trip to YAML with .day_of_week' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.weekly.day_of_week(:monday => [1, -2])
    
    yaml_string = schedule.to_yaml
    schedule2 = Schedule.from_yaml(yaml_string)
    
    #make sure they both have the same result
    schedule.first(10).should == schedule2.first(10)
  end

  it 'should be able to make a round-trip to YAML with .day_of_year' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.yearly.day_of_year(100, 200)
    
    yaml_string = schedule.to_yaml
    schedule2 = Schedule.from_yaml(yaml_string)
    
    #make sure they both have the same result
    schedule.first(10).should == schedule2.first(10)
  end

  it 'should be able to make a round-trip to YAML with .hour_of_day' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.daily.hour_of_day(1, 2)
    
    yaml_string = schedule.to_yaml
    schedule2 = Schedule.from_yaml(yaml_string)
    
    #make sure they both have the same result
    schedule.first(10).should == schedule2.first(10)
  end

  it 'should be able to make a round-trip to YAML with .minute_of_hour' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.daily.minute_of_hour(0, 30)
    
    yaml_string = schedule.to_yaml
    schedule2 = Schedule.from_yaml(yaml_string)
    
    #make sure they both have the same result
    schedule.first(10).should == schedule2.first(10)
  end

  it 'should be able to make a round-trip to YAML with .month_of_year' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.yearly.month_of_year(:april, :may)
    
    yaml_string = schedule.to_yaml
    schedule2 = Schedule.from_yaml(yaml_string)
    
    #make sure they both have the same result
    schedule.first(10).should == schedule2.first(10)
  end

  it 'should be able to make a round-trip to YAML with .second_of_minute' do
    schedule = Schedule.new(Time.now)
    schedule.add_recurrence_rule Rule.daily.second_of_minute(1, 2)
    
    yaml_string = schedule.to_yaml
    schedule2 = Schedule.from_yaml(yaml_string)
    
    #make sure they both have the same result
    schedule.first(10).should == schedule2.first(10)
  end

  it 'should have a to_yaml representation of a rule that does not contain ruby objects' do
    rule = IceCube::Rule.daily.day_of_week(:monday => [1, -1]).month_of_year(:april)
    rule.to_yaml.include?('object').should be false
  end

  it 'should have a to_yaml representation of a schedule that does not contain ruby objects' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.daily.day_of_week(:monday => [1, -1]).month_of_year(:april)
    schedule.to_yaml.include?('object').should be false
    puts schedule.to_yaml
  end

end