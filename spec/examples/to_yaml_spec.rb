require File.dirname(__FILE__) + "/../spec_helper"

module IceCube
  describe Schedule, "to_yaml" do
    before do
      require "active_support/time"
      Time.zone = "Eastern Time (US & Canada)"
    end

    [:yearly, :monthly, :weekly, :daily, :hourly, :minutely, :secondly].each do |type|
      it "should make a #{type} round trip with to_yaml [#47]" do
        schedule = Schedule.new(Time.zone.now)
        schedule.add_recurrence_rule Rule.send(type, 3)
        expect(Schedule.from_yaml(schedule.to_yaml).first(3).inspect).to eq(schedule.first(3).inspect)
      end
    end

    it "should be able to let rules take round trips to yaml" do
      schedule = Schedule.new
      schedule.add_recurrence_rule Rule.monthly
      schedule = Schedule.from_yaml schedule.to_yaml
      rule = schedule.rrules.first
      rule.is_a?(MonthlyRule)
    end

    it "should respond to .to_yaml" do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.until(Time.now)
      # check assumption
      expect(schedule).to respond_to("to_yaml")
    end

    it "should be able to make a round-trip to YAML" do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.until(Time.now + 10)
      result1 = schedule.all_occurrences

      yaml_string = schedule.to_yaml

      schedule2 = Schedule.from_yaml(yaml_string)
      result2 = schedule2.all_occurrences

      # compare without usecs
      expect(result1.map { |r| r.to_s }).to eq(result2.map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .day" do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.day(:monday, :wednesday)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .day_of_month" do
      schedule = Schedule.new(Time.zone.now)
      schedule.add_recurrence_rule Rule.monthly.day_of_month(10, 20)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .day_of_week" do
      schedule = Schedule.new(Time.zone.now)
      schedule.add_recurrence_rule Rule.weekly.day_of_week(monday: [1, -2])

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .day_of_year" do
      schedule1 = Schedule.new(Time.zone.now)
      schedule1.add_recurrence_rule Rule.yearly.day_of_year(100, 200)

      yaml_string = schedule1.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule2.first(10).map { |r| r.to_s })
        .to eq(schedule1.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .hour_of_day" do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.hour_of_day(1, 2)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .minute_of_hour" do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.minute_of_hour(0, 30)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .month_of_year" do
      schedule = Schedule.new(Time.zone.now)
      schedule.add_recurrence_rule Rule.yearly.month_of_year(:april, :may)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .second_of_minute" do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.second_of_minute(1, 2)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .by_set_pos (positive)" do
      # Use UTC to avoid DST/timezone issues that can cause infinite loops in BYSETPOS validation
      schedule = Schedule.new(Time.utc(2023, 6, 1, 12, 0, 0))
      schedule.add_recurrence_rule Rule.monthly.day(:monday, :wednesday, :friday).by_set_pos(1)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .by_set_pos (negative)" do
      # Use UTC to avoid DST/timezone issues that can cause infinite loops in BYSETPOS validation
      schedule = Schedule.new(Time.utc(2023, 6, 1, 12, 0, 0))
      schedule.add_recurrence_rule Rule.monthly.day(:monday, :tuesday, :wednesday, :thursday, :friday).by_set_pos(-1)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .by_set_pos (multiple positions)" do
      # Use UTC to avoid DST/timezone issues that can cause infinite loops in BYSETPOS validation
      schedule = Schedule.new(Time.utc(2023, 6, 1, 12, 0, 0))
      schedule.add_recurrence_rule Rule.weekly.day(:monday, :wednesday, :friday).by_set_pos(1, -1)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML with .by_set_pos on daily rule" do
      # Use UTC to avoid DST/timezone issues that can cause infinite loops in BYSETPOS validation
      schedule = Schedule.new(Time.utc(2023, 6, 1, 12, 0, 0))
      schedule.add_recurrence_rule Rule.daily.hour_of_day(9, 12, 15).by_set_pos(2)

      yaml_string = schedule.to_yaml
      schedule2 = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(schedule.first(10).map { |r| r.to_s }).to eq(schedule2.first(10).map { |r| r.to_s })
    end

    it "should be able to make a round-trip to YAML whilst preserving exception rules" do
      # Use UTC to avoid DST issues. YAML round-tripping loses timezone info (only
      # preserves numeric offset), so crossing a DST boundary would cause mismatched
      # offsets. UTC has no DST transitions.
      original_schedule = Schedule.new(Time.utc(2023, 6, 1, 12, 0, 0))
      original_schedule.add_recurrence_rule Rule.daily.day(:monday, :wednesday)
      original_schedule.add_exception_rule Rule.daily.day(:wednesday)

      yaml_string = original_schedule.to_yaml
      returned_schedule = Schedule.from_yaml(yaml_string)

      # compare without usecs
      expect(returned_schedule.first(10).map { |r| r.to_s }).to eq(original_schedule.first(10).map { |r| r.to_s })
    end

    it "should have a to_yaml representation of a rule that does not contain ruby objects" do
      rule = Rule.daily.day_of_week(monday: [1, -1]).month_of_year(:april)
      expect(rule.to_yaml.include?("object")).to be_falsey
    end

    it "should have a to_yaml representation of a schedule that does not contain ruby objects" do
      schedule = Schedule.new(Time.now)
      schedule.add_recurrence_rule Rule.daily.day_of_week(monday: [1, -1]).month_of_year(:april)
      expect(schedule.to_yaml.include?("object")).to be_falsey
    end

    # This test will fail when not run in Eastern Time
    # This is a bug because to_datetime will always convert to system local time
    it "should be able to roll forward times and get back times in an array - TimeWithZone", requires_active_support: true do
      Time.zone = "Eastern Time (US & Canada)"
      start_time = Time.zone.local(2011, 11, 5, 12, 0, 0)
      schedule = Schedule.new(start_time)
      schedule = Schedule.from_yaml(schedule.to_yaml) # round trip
      ice_cube_start_time = schedule.start_time
      expect(ice_cube_start_time).to eq(start_time)
      expect(ice_cube_start_time.utc_offset).to eq(start_time.utc_offset)
    end

    it "should be able to roll forward times and get back times in an array - Time" do
      start_time = Time.now
      schedule = Schedule.new(start_time)
      schedule = Schedule.from_yaml(schedule.to_yaml) # round trip
      ice_cube_start_time = schedule.start_time
      expect(ice_cube_start_time.to_s).to eq(start_time.to_s)
      expect(ice_cube_start_time.class).to eq(Time)
      expect(ice_cube_start_time.utc_offset).to eq(start_time.utc_offset)
    end

    it "should be able to go back and forth to yaml and then call occurrences" do
      start_time = Time.local(2011, 5, 10, 12, 0, 0)
      schedule1 = Schedule.new(start_time)
      schedule1.add_recurrence_time start_time
      schedule2 = Schedule.from_yaml(schedule1.to_yaml) # round trip

      end_time = Time.now + ONE_DAY
      expect(schedule2.occurrences(end_time)).to eq(schedule1.occurrences(end_time))
    end

    it "should be able to make a round trip with an exception time" do
      schedule = Schedule.new
      schedule.add_exception_time(time = Time.now)
      schedule = Schedule.from_yaml schedule.to_yaml
      expect(schedule.extimes.map(&:to_s)).to eq([time.to_s])
    end

    it "crazy shit" do
      start_time = Time.zone.now
      schedule = Schedule.new(start_time)

      schedule.add_recurrence_rule Rule.weekly.day(:wednesday)
      schedule.add_recurrence_time start_time

      schedule = Schedule.from_hash(schedule.to_hash)
      schedule = Schedule.from_yaml(schedule.to_yaml)

      schedule.occurrences(start_time + ONE_DAY * 14)
    end

    it "should be able to make a round trip to hash with a duration" do
      schedule = Schedule.new Time.now, duration: 3600
      expect(Schedule.from_hash(schedule.to_hash).duration).to eq(3600)
    end

    it "should be able to be serialized to yaml as part of a hash" do
      schedule = Schedule.new Time.now
      hash = {schedule: schedule}
      expect do
        hash.to_yaml
      end.not_to raise_error
    end

    it "should be able to roll forward and back in time" do
      schedule = Schedule.new(Time.now)
      rt_schedule = Schedule.from_yaml(schedule.to_yaml)
      expect(rt_schedule.start_time.utc_offset).to eq(schedule.start_time.utc_offset)
    end

    it "should be backward compatible with old yaml Time format", expect_warnings: true do
      yaml = "---\n:end_time:\n:rdates: []\n:rrules: []\n:duration:\n:exdates: []\n:start_time: 2010-10-18T14:35:47-07:00"
      schedule = Schedule.from_yaml(yaml)
      expect(schedule.start_time).to be_a(Time)
    end

    it "should work to_yaml with non-TimeWithZone" do
      schedule = Schedule.new(Time.now)
      expect(schedule.to_yaml.length).to be < 200
    end

    it "should work with occurs_on and TimeWithZone" do
      pacific_time = "Pacific Time (US & Canada)"
      Time.zone = pacific_time
      schedule = Schedule.new(Time.zone.now)
      schedule.add_recurrence_rule Rule.weekly
      expect(schedule.occurs_on?(schedule.start_time.to_date + 6)).to be_falsey
      expect(schedule.occurs_on?(schedule.start_time.to_date + 7)).to be_truthy
      expect(schedule.occurs_on?(schedule.start_time.to_date + 8)).to be_falsey
    end

    it "should work with occurs_on and TimeWithZone" do
      start_time = Time.zone.local(2012, 7, 15, 12, 0, 0)
      pacific_time = "Pacific Time (US & Canada)"
      Time.zone = pacific_time
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_time start_time + 7 * ONE_DAY
      expect(schedule.occurs_on?(schedule.start_time.to_date + 6)).to be_falsey
      expect(schedule.occurs_on?(schedule.start_time.to_date + 7)).to be_truthy
      expect(schedule.occurs_on?(schedule.start_time.to_date + 8)).to be_falsey
    end

    it "should crazy patch" do
      Time.zone = "Pacific Time (US & Canada)"
      day = Time.zone.parse("21 Oct 2010 02:00:00")
      schedule = Schedule.new(day)
      schedule.add_recurrence_time(day)
      expect(schedule.occurs_on?(Date.new(2010, 10, 20))).to be_falsey
      expect(schedule.occurs_on?(Date.new(2010, 10, 21))).to be_truthy
      expect(schedule.occurs_on?(Date.new(2010, 10, 22))).to be_falsey
    end

    it "should be able to bring a Rule to_yaml and back with a timezone" do
      Time.zone = "Pacific Time (US & Canada)"
      time = Time.now
      offset = time.utc_offset
      rule = Rule.daily.until(time)
      rule = Rule.from_yaml(rule.to_yaml)
      expect(rule.until_time.utc_offset).to eq(offset)
    end

    it "should be able to bring a Rule to_yaml and back with a count" do
      rule = Rule.daily.count(5)
      rule = Rule.from_yaml rule.to_yaml
      expect(rule.occurrence_count).to eq(5)
    end

    it "should be able to bring a Rule to_yaml and back with an until Date" do
      rule = Rule.daily.until(Date.today >> 1)
      rule = Rule.from_yaml rule.to_yaml
      expect(rule.until_time).to eq(Date.today >> 1)
    end

    it "should be able to bring a Rule to_yaml and back with an until Time" do
      t1 = Time.now + ONE_HOUR
      rule = Rule.daily.until(t1)
      rule = Rule.from_yaml rule.to_yaml
      expect(rule.until_time).to eq(t1)
    end

    it "should be able to bring a Rule to_yaml and back with an until TimeWithZone" do
      Time.zone = "America/Vancouver"
      t1 = Time.zone.now + ONE_HOUR
      rule = Rule.daily.until(t1)
      rule = Rule.from_yaml rule.to_yaml
      expect(rule.until_time).to eq(t1)
    end

    it "should be able to bring a Rule to_yaml and back with an undefined week start" do
      rule = Rule.weekly(2)
      rule = Rule.from_yaml rule.to_yaml
      expect(rule.week_start).to eq(:sunday)
    end

    it "should be able to bring a Rule to_yaml and back with a week start defined" do
      rule = Rule.weekly.interval(2, :monday)
      rule = Rule.from_yaml rule.to_yaml
      expect(rule.week_start).to eq(:monday)
    end

    it "should be able to bring in a schedule with a rule from hash with symbols or strings" do
      time = Time.zone.now
      symbol_data = {start_time: time, rrules: [{validations: {day: [1]}, rule_type: "IceCube::DailyRule", interval: 1}], rtimes: [], extimes: []}
      string_data = {"start_time" => time, "rrules" => [{"validations" => {"day" => [1]}, "rule_type" => "IceCube::DailyRule", "interval" => 1}], "rtimes" => [], "extimes" => []}

      symbol_yaml = Schedule.from_hash(symbol_data).to_yaml
      string_yaml = Schedule.from_hash(string_data).to_yaml
      # Ruby 2.6-3.0 use positional args, Ruby 3.1+ uses keyword args for YAML.safe_load
      if RUBY_VERSION < "3.1"
        expect(YAML.safe_load(symbol_yaml, [Symbol, Time]))
          .to eq(YAML.safe_load(string_yaml, [Symbol, Time]))
      else
        expect(YAML.safe_load(symbol_yaml, permitted_classes: [Symbol, Time]))
          .to eq(YAML.safe_load(string_yaml, permitted_classes: [Symbol, Time]))
      end
    end

    it "should raise an ArgumentError when trying to deserialize an invalid rule type" do
      data = {rule_type: "IceCube::FakeRule", interval: 1}
      expect { Rule.from_hash(data) }.to raise_error(ArgumentError, "Invalid rule frequency type: Fake")
    end

    it "should raise an ArgumentError when trying to deserialize an invalid validation" do
      data = {validations: {fake: []}, rule_type: "IceCube::DailyRule", interval: 1}
      expect { Rule.from_hash(data) }.to raise_error(ArgumentError, "Invalid rule validation type: fake")
    end
  end
end
