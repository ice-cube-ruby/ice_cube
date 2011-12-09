require File.dirname(__FILE__) + '/../spec_helper'
require 'active_support/time'

Time.zone = 'Eastern Time (US & Canada)'

describe IceCube::Schedule, 'to_yaml' do

  [:yearly, :monthly, :weekly, :daily, :hourly, :minutely, :secondly].each do |type|
    it "should make a #{type} round trip with to_yaml - github issue 47" do
      s = Schedule.new(Time.now)
      s.add_recurrence_rule Rule.send(type, 3)
      Schedule.from_yaml(s.to_yaml).first(3).should == s.first(3)
    end
  end

  it 'should be able to let rules take round trips to yaml' do
    schedule = IceCube::Schedule.new
    schedule.add_recurrence_rule IceCube::Rule.monthly
    schedule = IceCube::Schedule.from_yaml schedule.to_yaml
    rule = schedule.rrules.first
    rule.is_a?(IceCube::MonthlyRule)
  end
  
  it 'should respond to .to_yaml' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.daily.until(Time.now)
    #check assumption
    schedule.should respond_to('to_yaml')
  end
  
  it 'should be able to make a round-trip to YAML' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.daily.until(Time.now + 10)
    result1 = schedule.all_occurrences
    
    yaml_string = schedule.to_yaml
    
    schedule2 = IceCube::Schedule.from_yaml(yaml_string)
    result2 = schedule2.all_occurrences
    
    # compare without usecs
    result1.map { |r| r.to_s }.should == result2.map { |r| r.to_s }    
  end

  it 'should be able to make a round-trip to YAML with .day' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.daily.day(:monday, :wednesday)
    
    yaml_string = schedule.to_yaml
    schedule2 = IceCube::Schedule.from_yaml(yaml_string)
    
    # compare without usecs
    schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }    
  end

  it 'should be able to make a round-trip to YAML with .day_of_month' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(10, 20)
    
    yaml_string = schedule.to_yaml
    schedule2 = IceCube::Schedule.from_yaml(yaml_string)

    # compare without usecs
    schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }    
  end

  it 'should be able to make a round-trip to YAML with .day_of_week' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(:monday => [1, -2])
    
    yaml_string = schedule.to_yaml
    schedule2 = IceCube::Schedule.from_yaml(yaml_string)

    # compare without usecs
    schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }    
  end

  it 'should be able to make a round-trip to YAML with .day_of_year' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(100, 200)
    
    yaml_string = schedule.to_yaml
    schedule2 = IceCube::Schedule.from_yaml(yaml_string)
    
    # compare without usecs
    schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }    
  end

  it 'should be able to make a round-trip to YAML with .hour_of_day' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.daily.hour_of_day(1, 2)
    
    yaml_string = schedule.to_yaml
    schedule2 = IceCube::Schedule.from_yaml(yaml_string)

    # compare without usecs
    schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }    
  end

  it 'should be able to make a round-trip to YAML with .minute_of_hour' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.daily.minute_of_hour(0, 30)
    
    yaml_string = schedule.to_yaml
    schedule2 = IceCube::Schedule.from_yaml(yaml_string)

    # compare without usecs
    schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }    
  end

  it 'should be able to make a round-trip to YAML with .month_of_year' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:april, :may)
    
    yaml_string = schedule.to_yaml
    schedule2 = IceCube::Schedule.from_yaml(yaml_string)

    # compare without usecs
    schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }    
  end

  it 'should be able to make a round-trip to YAML with .second_of_minute' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.daily.second_of_minute(1, 2)
    
    yaml_string = schedule.to_yaml
    schedule2 = IceCube::Schedule.from_yaml(yaml_string)

    # compare without usecs
    schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }    
  end

  it 'should have a to_yaml representation of a rule that does not contain ruby objects' do
    rule = IceCube::Rule.daily.day_of_week(:monday => [1, -1]).month_of_year(:april)
    rule.to_yaml.include?('object').should be(false)
  end

  it 'should have a to_yaml representation of a schedule that does not contain ruby objects' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.daily.day_of_week(:monday => [1, -1]).month_of_year(:april)
    schedule.to_yaml.include?('object').should be(false)
  end

  # This test will fail when not run in Eastern Time
  # This is a bug because to_datetime will always convert to system local time
  it 'should be able to roll forward times and get back times in an array - TimeWithZone' do
    Time.zone = "Eastern Time (US & Canada)"
    start_date = Time.zone.local(2011, 11, 5, 12, 0, 0)
    schedule = IceCube::Schedule.new(start_date)
    schedule = IceCube::Schedule.from_yaml(schedule.to_yaml) # round trip
    ice_cube_start_date = schedule.start_date
    ice_cube_start_date.should == start_date
    ice_cube_start_date.utc_offset.should == start_date.utc_offset
  end
  
  it 'should be able to roll forward times and get back times in an array - Time' do
    start_date = Time.now
    schedule = IceCube::Schedule.new(start_date)
    schedule = IceCube::Schedule.from_yaml(schedule.to_yaml) # round trip
    ice_cube_start_date = schedule.start_date
    ice_cube_start_date.to_s.should == start_date.to_s
    ice_cube_start_date.class.should == Time
    ice_cube_start_date.utc_offset.should == start_date.utc_offset
  end

  it 'should be able to go back and forth to yaml and then call occurrences' do
    start_date = Time.local(2011, 5, 10, 12, 0, 0)
    schedule1 = IceCube::Schedule.new(start_date)
    schedule1.add_recurrence_date start_date
    schedule2 = IceCube::Schedule.from_yaml(schedule1.to_yaml) # round trip

    end_time = Time.now + IceCube::ONE_DAY
    schedule1.occurrences(end_time).should == schedule2.occurrences(end_time)
  end

  it 'should be able to make a round trip with an exdate' do
    schedule = IceCube::Schedule.new
    schedule.add_exception_time (time = Time.now)
    schedule = IceCube::Schedule.from_yaml schedule.to_yaml
    schedule.exdates.map(&:to_s).should == [time.to_s]
  end

  it 'crazy shit' do
    start_date = Time.zone.now
    schedule = IceCube::Schedule.new(start_date)
    
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(:wednesday)
    schedule.add_recurrence_date start_date

    schedule = IceCube::Schedule.from_hash(schedule.to_hash)
    schedule = IceCube::Schedule.from_yaml(schedule.to_yaml)

    schedule.occurrences(start_date + IceCube::ONE_DAY * 14)
  end

  it 'should be able to make a round trip to hash with a duration' do
    schedule = IceCube::Schedule.new Time.now, :duration => 3600
    IceCube::Schedule.from_hash(schedule.to_hash).duration.should == 3600
  end

  it 'should be able to be serialized to yaml as part of a hash' do
    schedule = IceCube::Schedule.new Time.now
    hash = { :schedule => schedule }
    lambda do
      hash.to_yaml
    end.should_not raise_error
  end

  it 'should be able to roll forward and back in time' do
    schedule = IceCube::Schedule.new(Time.now)
    rt_schedule = IceCube::Schedule.from_yaml(schedule.to_yaml)
    rt_schedule.start_time.utc_offset.should == schedule.start_time.utc_offset
  end

  it 'should be backward compatible with old yaml Time format' do
    pacific_time = 'Pacific Time (US & Canada)'
    yaml = "---\n:end_time:\n:rdates: []\n:rrules: []\n:duration:\n:exdates: []\n:exrules: []\n:start_date: 2010-10-18T14:35:47-07:00"
    schedule = IceCube::Schedule.from_yaml(yaml)
    schedule.start_time.should be_a(Time)
  end

  it 'should work to_yaml with non-TimeWithZone' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.to_yaml.length.should be < 200
  end

  it 'should work with occurs_on and TimeWithZone' do
    pacific_time = 'Pacific Time (US & Canada)'
    Time.zone = pacific_time
    schedule = IceCube::Schedule.new(Time.zone.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.occurs_on?(schedule.start_date.to_date + 6).should be(false)
    schedule.occurs_on?(schedule.start_date.to_date + 7).should be(true)
    schedule.occurs_on?(schedule.start_date.to_date + 8).should be(false)
  end

  it 'should work with occurs_on and TimeWithZone' do
    pacific_time = 'Pacific Time (US & Canada)'
    Time.zone = pacific_time
    schedule = IceCube::Schedule.new(Time.zone.now)
    schedule.add_recurrence_date Time.zone.now + 7 * IceCube::ONE_DAY
    schedule.occurs_on?(schedule.start_date.to_date + 6).should be(false)
    schedule.occurs_on?(schedule.start_date.to_date + 7).should be(true)
    schedule.occurs_on?(schedule.start_date.to_date + 8).should be(false)
  end

  it 'should crazy patch' do
    Time.zone = 'Pacific Time (US & Canada)'
    day = Time.zone.parse('21 Oct 2010 02:00:00')
    schedule = IceCube::Schedule.new(day)
    schedule.add_recurrence_date(day)
    schedule.occurs_on?(Date.new(2010, 10, 20)).should be(false)
    schedule.occurs_on?(Date.new(2010, 10, 21)).should be(true)
    schedule.occurs_on?(Date.new(2010, 10, 22)).should be(false)
  end

  it 'should be able to bring a Rule to_yaml and back with a timezone' do
    Time.zone = 'Pacific Time (US & Canada)'
    time = Time.now
    offset = time.utc_offset
    rule = IceCube::Rule.daily.until(time)
    rule = IceCube::Rule.from_yaml(rule.to_yaml)
    rule.until_date.utc_offset.should == offset
  end

  it 'should be able to bring a Rule to_yaml and back with a count' do
    rule = IceCube::Rule.daily.count(5)
    rule = IceCube::Rule.from_yaml rule.to_yaml
    rule.occurrence_count.should == 5
  end

end
