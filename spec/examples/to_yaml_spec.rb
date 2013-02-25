require File.dirname(__FILE__) + '/../spec_helper'
require 'active_support/time'

module IceCube
  describe Schedule, 'to_yaml' do

    before(:all) { Time.zone = 'Eastern Time (US & Canada)' }

    [:yearly, :monthly, :weekly, :daily, :hourly, :minutely, :secondly].each do |type|
      it "should make a #{type} round trip with to_yaml [#47]" do
        schedule = Schedule.new(t0 = Time.now)
        schedule.add_recurrence_rule Rule.send(type, 3)
        Schedule.from_yaml(schedule.to_yaml).first(3).should == schedule.first(3)
      end
    end

    it 'should be able to let rules take round trips to yaml' do
      schedule = Schedule.new
      schedule.add_recurrence_rule Rule.monthly
      schedule = Schedule.from_yaml schedule.to_yaml
      rule = schedule.rrules.first
      rule.is_a?(MonthlyRule)
    end

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

      # compare without usecs
      result1.map { |r| r.to_s }.should == result2.map { |r| r.to_s }
    end

    it 'should be able to make a round-trip to YAML with .day' do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.day(:monday, :wednesday)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }
    end

    it 'should be able to make a round-trip to YAML with .day_of_month' do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.monthly.day_of_month(10, 20)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }
    end

    it 'should be able to make a round-trip to YAML with .day_of_week' do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.weekly.day_of_week(:monday => [1, -2])

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }
    end

    it 'should be able to make a round-trip to YAML with .day_of_year' do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.yearly.day_of_year(100, 200)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }
    end

    it 'should be able to make a round-trip to YAML with .hour_of_day' do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.hour_of_day(1, 2)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }
    end

    it 'should be able to make a round-trip to YAML with .minute_of_hour' do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.minute_of_hour(0, 30)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }
    end

    it 'should be able to make a round-trip to YAML with .month_of_year' do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.yearly.month_of_year(:april, :may)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }
    end

    it 'should be able to make a round-trip to YAML with .second_of_minute' do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.second_of_minute(1, 2)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      schedule.first(10).map { |r| r.to_s }.should == schedule2.first(10).map { |r| r.to_s }
    end

    it 'should have a to_yaml representation of a rule that does not contain ruby objects' do
      rule = Rule.daily.day_of_week(:monday => [1, -1]).month_of_year(:april)
      rule.to_yaml.include?('object').should be_false
    end

    it 'should have a to_yaml representation of a schedule that does not contain ruby objects' do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.day_of_week(:monday => [1, -1]).month_of_year(:april)
      schedule.to_yaml.include?('object').should be_false
    end

    # This test will fail when not run in Eastern Time
    # This is a bug because to_datetime will always convert to system local time
    it 'should be able to roll forward times and get back times in an array - TimeWithZone', :if_active_support_time => true do
      Time.zone = "Eastern Time (US & Canada)"
      start_date = Time.zone.local(2011, 11, 5, 12, 0, 0)
      schedule = Schedule.new(start_date)
      schedule = Schedule.from_yaml(schedule.to_yaml) # round trip
      ice_cube_start_date = schedule.start_time
      ice_cube_start_date.should == start_date
      ice_cube_start_date.utc_offset.should == start_date.utc_offset
    end

    it 'should be able to roll forward times and get back times in an array - Time' do
      start_date = Time.now
      schedule = Schedule.new(start_date)
      schedule = Schedule.from_yaml(schedule.to_yaml) # round trip
      ice_cube_start_date = schedule.start_time
      ice_cube_start_date.to_s.should == start_date.to_s
      ice_cube_start_date.class.should == Time
      ice_cube_start_date.utc_offset.should == start_date.utc_offset
    end

    it 'should be able to go back and forth to yaml and then call occurrences' do
      start_date = Time.local(2011, 5, 10, 12, 0, 0)
      schedule1 = Schedule.new(start_date)
      schedule1.add_recurrence_time start_date
      schedule2 = Schedule.from_yaml(schedule1.to_yaml) # round trip

      end_time = Time.now + ONE_DAY
      schedule1.occurrences(end_time).should == schedule2.occurrences(end_time)
    end

    it 'should be able to make a round trip with an exception time' do
      schedule = Schedule.new
      schedule.add_exception_time(time = Time.now)
      schedule = Schedule.from_yaml schedule.to_yaml
      schedule.extimes.map(&:to_s).should == [time.to_s]
    end

    it 'crazy shit' do
      start_date = Time.zone.now
      schedule = Schedule.new(start_date)

      schedule.add_recurrence_rule Rule.weekly.day(:wednesday)
      schedule.add_recurrence_time start_date

      schedule = Schedule.from_hash(schedule.to_hash)
      schedule = Schedule.from_yaml(schedule.to_yaml)

      schedule.occurrences(start_date + ONE_DAY * 14)
    end

    it 'should be able to make a round trip to hash with a duration' do
      schedule = Schedule.new Time.now, :duration => 3600
      Schedule.from_hash(schedule.to_hash).duration.should == 3600
    end

    it 'should be able to be serialized to yaml as part of a hash' do
      schedule = Schedule.new Time.now
      hash = { :schedule => schedule }
      lambda do
        hash.to_yaml
      end.should_not raise_error
    end

    it 'should be able to roll forward and back in time' do
      schedule = Schedule.new(Time.now)
      rt_schedule = Schedule.from_yaml(schedule.to_yaml)
      rt_schedule.start_time.utc_offset.should == schedule.start_time.utc_offset
    end

    it 'should be backward compatible with old yaml Time format' do
      pacific_time = 'Pacific Time (US & Canada)'
      yaml = "---\n:end_time:\n:rdates: []\n:rrules: []\n:duration:\n:exdates: []\n:exrules: []\n:start_date: 2010-10-18T14:35:47-07:00"
      schedule = Schedule.from_yaml(yaml)
      schedule.start_time.should be_a(Time)
    end

    it 'should work to_yaml with non-TimeWithZone' do
      schedule = Schedule.new(Time.now)
      schedule.to_yaml.length.should be < 200
    end

    it 'should work with occurs_on and TimeWithZone' do
      pacific_time = 'Pacific Time (US & Canada)'
      Time.zone = pacific_time
      schedule = Schedule.new(Time.zone.now)
      schedule.add_recurrence_rule Rule.weekly
      schedule.occurs_on?(schedule.start_time.to_date + 6).should be_false
      schedule.occurs_on?(schedule.start_time.to_date + 7).should be_true
      schedule.occurs_on?(schedule.start_time.to_date + 8).should be_false
    end

    it 'should work with occurs_on and TimeWithZone' do
      start_time = Time.zone.local(2012, 7, 15, 12, 0, 0)
      pacific_time = 'Pacific Time (US & Canada)'
      Time.zone = pacific_time
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_time start_time + 7 * ONE_DAY
      schedule.occurs_on?(schedule.start_time.to_date + 6).should be_false
      schedule.occurs_on?(schedule.start_time.to_date + 7).should be_true
      schedule.occurs_on?(schedule.start_time.to_date + 8).should be_false
    end

    it 'should crazy patch' do
      Time.zone = 'Pacific Time (US & Canada)'
      day = Time.zone.parse('21 Oct 2010 02:00:00')
      schedule = Schedule.new(day)
      schedule.add_recurrence_time(day)
      schedule.occurs_on?(Date.new(2010, 10, 20)).should be_false
      schedule.occurs_on?(Date.new(2010, 10, 21)).should be_true
      schedule.occurs_on?(Date.new(2010, 10, 22)).should be_false
    end

    it 'should be able to bring a Rule to_yaml and back with a timezone' do
      Time.zone = 'Pacific Time (US & Canada)'
      time = Time.now
      offset = time.utc_offset
      rule = Rule.daily.until(time)
      rule = Rule.from_yaml(rule.to_yaml)
      rule.until_date.utc_offset.should == offset
    end

    it 'should be able to bring a Rule to_yaml and back with a count' do
      rule = Rule.daily.count(5)
      rule = Rule.from_yaml rule.to_yaml
      rule.occurrence_count.should == 5
    end

    it 'should be able to bring a Rule to_yaml and back with an undefined week start' do
      rule = Rule.weekly(2)
      rule = Rule.from_yaml rule.to_yaml
      rule.week_start.should == :sunday
    end

    it 'should be able to bring a Rule to_yaml and back with a week start defined' do
      rule = Rule.weekly.interval(2, :monday)
      rule = Rule.from_yaml rule.to_yaml
      rule.week_start.should == :monday
    end

    it 'should be able to bring in a schedule with a rule from hash with symbols or strings' do
      time = Time.zone.now
      symbol_data = { :start_date => time, :rrules =>   [ { :validations => { :day => [1] }, :rule_type => "IceCube::DailyRule", :interval => 1 } ], :exrules => [], :rtimes => [], :extimes => [] }
      string_data = { 'start_date' => time, 'rrules' => [ { 'validations' => { 'day' => [1] }, 'rule_type' => "IceCube::DailyRule", 'interval' => 1 } ], 'exrules' => [], 'rtimes' => [], 'extimes' => [] }

      symbol_yaml = Schedule.from_hash(symbol_data).to_yaml
      string_yaml = Schedule.from_hash(string_data).to_yaml
      symbol_yaml.should == string_yaml
    end

  end
end
