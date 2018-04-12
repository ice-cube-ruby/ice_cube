require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe HourlyRule do
    describe 'interval validation' do
      it 'converts a string integer to an actual int when using the interval method' do
        rule = Rule.hourly.interval("2")
        expect(rule.validations_for(:interval).first.interval).to eq(2)
      end

      it 'converts a string integer to an actual int when using the initializer' do
        rule = Rule.hourly("3")
        expect(rule.validations_for(:interval).first.interval).to eq(3)
      end

      it 'raises an argument error when a bad value is passed' do
        expect {
          Rule.hourly("invalid")
        }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
      end

      it 'raises an argument error when a bad value is passed using the interval method' do
        expect {
          Rule.hourly.interval("invalid")
        }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
      end
    end

    context 'in Vancouver time', :system_time_zone => 'America/Vancouver' do

      it 'should work across DST start hour' do
        schedule = Schedule.new(Time.local(2013, 3, 10, 1, 0, 0))
        schedule.add_recurrence_rule Rule.hourly
        expect(schedule.first(3)).to eq([
          Time.local(2013, 3, 10, 1, 0, 0), # -0800
          Time.local(2013, 3, 10, 3, 0, 0), # -0700
          Time.local(2013, 3, 10, 4, 0, 0)  # -0700
        ])
      end

      it 'should not skip times in DST end hour' do
        schedule = Schedule.new(Time.local(2013, 11, 3, 0, 0, 0))
        schedule.add_recurrence_rule Rule.hourly
        expect(schedule.first(4)).to eq([
          Time.local(2013, 11, 3, 0, 0, 0),             # -0700
          Time.local(2013, 11, 3, 1, 0, 0) - ONE_HOUR,  # -0700
          Time.local(2013, 11, 3, 1, 0, 0),             # -0800
          Time.local(2013, 11, 3, 2, 0, 0),             # -0800
        ])
      end

    end

    it 'should update previous interval' do
      t0 = Time.now
      rule = Rule.hourly(7)
      rule.interval(5)
      expect(rule.next_time(t0 + 1, t0, nil)).to eq(t0 + 5 * ONE_HOUR)
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

    it "should realign to the first hour_of_day with interval" do
      t0 = Time.utc(2017, 1, 1, 20, 30, 40)
      schedule = IceCube::Schedule.new(t0)
      schedule.rrule IceCube::Rule.hourly(5).hour_of_day(5, 10)

      expect(schedule.first(3)).to eq [
        t0,
        t0 + 9*ONE_HOUR,
        t0 + 14*ONE_HOUR,
      ]
    end

    it "should realign to the first hour_of_day without interval" do
      t0 = Time.utc(2017, 1, 1, 20, 30, 40)
      schedule = IceCube::Schedule.new(t0)
      schedule.rrule IceCube::Rule.hourly.hour_of_day(5, 10)

      expect(schedule.first(3)).to eq [
        t0,
        t0 + 9*ONE_HOUR,
        t0 + 14*ONE_HOUR,
      ]
    end

    it "raises errors for misaligned interval and hour_of_day values" do
      expect {
        IceCube::Rule.hourly(10).hour_of_day(3, 6)
      }.to raise_error(ArgumentError, "intervals in hour_of_day(3, 6) must be multiples of interval(10)")
    end

    it "raises errors for misaligned hour_of_day values when changing interval" do
      expect {
        IceCube::Rule.hourly(3).hour_of_day(3, 6).interval(5)
      }.to raise_error(ArgumentError, "interval(5) must be a multiple of intervals in hour_of_day(3, 6)")
    end

  end
end
