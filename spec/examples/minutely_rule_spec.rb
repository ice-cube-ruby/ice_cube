require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::MinutelyRule do

  describe 'interval validation' do
    it 'converts a string integer to an actual int when using the interval method' do
      rule = Rule.minutely.interval("2")
      expect(rule.validations_for(:interval).first.interval).to eq(2)
    end

    it 'converts a string integer to an actual int when using the initializer' do
      rule = Rule.minutely("3")
      expect(rule.validations_for(:interval).first.interval).to eq(3)
    end

    it 'raises an argument error when a bad value is passed' do
      expect {
        Rule.minutely("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
    end

    it 'raises an argument error when a bad value is passed when using the interval method' do
      expect {
        Rule.minutely.interval("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
    end
  end

    it 'should update previous interval' do
      t0 = Time.now
      rule = Rule.minutely(7)
      rule.interval(5)
      expect(rule.next_time(t0 + 1, t0, nil)).to eq(t0 + 5 * IceCube::ONE_MINUTE)
    end

    it 'should work across DST start hour' do
      std_end = Time.local(2013, 3, 10, 1, 59, 0)
      schedule = Schedule.new(std_end)
      schedule.add_recurrence_rule Rule.minutely
      expect(schedule.first(3)).to eq([
        std_end,
        std_end + ONE_MINUTE,
        std_end + ONE_MINUTE * 2
      ])
    end

    it 'should not skip DST end hour' do
      std_start = Time.local(2013, 11, 3, 1, 0, 0)
      schedule = Schedule.new(std_start - 60)
      schedule.add_recurrence_rule Rule.minutely
      expect(schedule.first(3)).to eq([
        std_start - ONE_MINUTE,
        std_start,
        std_start + ONE_MINUTE
      ])
    end

    it 'should produce the correct days for @interval = 3' do
      start_time = DAY
      schedule = Schedule.new(start_time)
      schedule = Schedule.from_yaml(schedule.to_yaml)
      schedule.add_recurrence_rule Rule.hourly(3)
      #check assumption (3) -- (1) 2 (3) 4 (5) 6
      dates = schedule.first(3)
      expect(dates.size).to eq(3)
      expect(dates).to eq([DAY, DAY + 3 * ONE_HOUR, DAY + 6 * ONE_HOUR])
    end

    it 'should produce the correct minutes starting with an offset' do
      schedule = Schedule.new Time.new(2013, 11, 1, 1, 3, 0)
      schedule.rrule Rule.minutely(5)
      expect(schedule.next_occurrence(Time.new(2013, 11, 1, 1, 4, 0))).to eq(Time.new(2013, 11, 1, 1, 8, 0))
    end

    it "should realign to the first minute_of_hour" do
      t0 = Time.utc(2017, 1, 1, 20, 30, 40)
      schedule = IceCube::Schedule.new(t0)
      schedule.rrule IceCube::Rule.minutely(10).minute_of_hour(5, 15)

      expect(schedule.first(3)).to eq [
        t0,
        t0 + 35*ONE_MINUTE,
        t0 + 45*ONE_MINUTE,
      ]
    end

    it "raises errors for misaligned interval and minute_of_hour values" do
      expect {
        IceCube::Rule.minutely(10).minute_of_hour(3, 6)
      }.to raise_error(ArgumentError, "intervals in minute_of_hour(3, 6) must be multiples of interval(10)")
    end

    it "raises errors for misaligned minute_of_hour values when changing interval" do
      expect {
        IceCube::Rule.minutely(3).minute_of_hour(3, 6).interval(5)
      }.to raise_error(ArgumentError, "interval(5) must be a multiple of intervals in minute_of_hour(3, 6)")
    end

end
