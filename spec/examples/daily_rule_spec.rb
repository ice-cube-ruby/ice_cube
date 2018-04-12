require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe DailyRule, 'interval validation' do
    it 'converts a string integer to an actual int when using the interval method' do
      rule = Rule.daily.interval("2")
      expect(rule.validations_for(:interval).first.interval).to eq(2)
    end

    it 'converts a string integer to an actual int when using the initializer' do
      rule = Rule.daily("3")
      expect(rule.validations_for(:interval).first.interval).to eq(3)
    end

    it 'raises an argument error when a bad value is passed using the interval method' do
      expect {
        Rule.daily.interval("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
    end

    it 'raises an argument error when a bad value is passed' do
      expect {
        Rule.daily("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
    end
  end

  describe DailyRule do

    describe 'in Vancouver time', :system_time_zone => 'America/Vancouver' do

      it 'should include nearest time in DST start hour' do
        schedule = Schedule.new(Time.local(2013, 3, 9, 2, 30, 0))
        schedule.add_recurrence_rule Rule.daily
        expect(schedule.first(3)).to eq([
          Time.local(2013, 3,  9, 2, 30, 0), # -0800
          Time.local(2013, 3, 10, 3, 30, 0), # -0700
          Time.local(2013, 3, 11, 2, 30, 0)  # -0700
        ])
      end

      it 'should not skip times in DST end hour' do
        schedule = Schedule.new(Time.local(2013, 11, 2, 2, 30, 0))
        schedule.add_recurrence_rule Rule.daily
        expect(schedule.first(3)).to eq([
          Time.local(2013, 11, 2, 2, 30, 0), # -0700
          Time.local(2013, 11, 3, 2, 30, 0), # -0800
          Time.local(2013, 11, 4, 2, 30, 0)  # -0800
        ])
      end

      it 'should include nearest time to DST start when locking hour_of_day' do
        schedule = Schedule.new(Time.local(2013, 3, 9, 2, 0, 0))
        schedule.add_recurrence_rule Rule.daily.hour_of_day(2)
        expect(schedule.first(3)).to eq([
          Time.local(2013, 3,  9, 2, 0, 0), # -0800
          Time.local(2013, 3, 10, 3, 0, 0), # -0700
          Time.local(2013, 3, 11, 2, 0, 0)  # -0700
        ])
      end

    end

    it 'should update previous interval' do
      t0 = Time.now
      rule = Rule.daily(7)
      rule.interval(5)
      expect(rule.next_time(t0 + 1, t0, nil)).to eq(t0 + 5 * ONE_DAY)
    end

    it 'should produce the correct days for @interval = 1' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.daily
      #check assumption
      times = schedule.occurrences(t0 + 2 * ONE_DAY)
      expect(times.size).to eq(3)
      expect(times).to eq([t0, t0 + ONE_DAY, t0 + 2 * ONE_DAY])
    end

    it 'should produce the correct days for @interval = 2' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.daily(2)
      #check assumption (3) -- (1) 2 (3) 4 (5) 6
      times = schedule.occurrences(t0 + 5 * ONE_DAY)
      expect(times.size).to eq(3)
      expect(times).to eq([t0, t0 + 2 * ONE_DAY, t0 + 4 * ONE_DAY])
    end

    it 'should produce the correct days for @interval = 2 when crossing into a new year' do
      schedule = Schedule.new(t0 = Time.utc(2011, 12, 29))
      schedule.add_recurrence_rule Rule.daily(2)
      #check assumption (3) -- (1) 2 (3) 4 (5) 6
      times = schedule.occurrences(t0 + 5 * ONE_DAY)
      expect(times.size).to eq(3)
      expect(times).to eq([t0, t0 + 2 * ONE_DAY, t0 + 4 * ONE_DAY])
    end

    it 'should produce the correct days for interval of 4 day with hour and minute of day set' do
      schedule = Schedule.new(t0 = Time.local(2010, 3, 1))
      schedule.add_recurrence_rule Rule.daily(4).hour_of_day(5).minute_of_hour(45)
      #check assumption 2 -- 1 (2) (3) (4) 5 (6)
      times = schedule.occurrences(t0 + 5 * ONE_DAY)
      expect(times).to eq([
        t0,
        t0 + 5 * ONE_HOUR + 45 * ONE_MINUTE,
        t0 + 4 * ONE_DAY + 5 * ONE_HOUR + 45 * ONE_MINUTE
      ])
    end

    describe "day validation" do
      it "allows multiples of 7" do
        expect { IceCube::Rule.daily(21).day(2, 4) }.to_not raise_error
      end

      it "raises errors for misaligned interval and day (wday) values" do
        expect {
          IceCube::Rule.daily(2).day(2, 4)
        }.to raise_error(ArgumentError, "day can only be used with multiples of interval(7)")
      end

      it "raises errors for misaligned hour_of_day values when changing interval" do
        expect {
          IceCube::Rule.daily.day(3, 6).interval(5)
        }.to raise_error(ArgumentError, "day can only be used with multiples of interval(7)")
      end
    end

    describe "day_of_month validation" do
      it "raises errors for misaligned interval and day_of_month values" do
        expect {
          IceCube::Rule.daily(2).day_of_month(2, 4)
        }.to raise_error(ArgumentError, "day_of_month can only be used with interval(1)")
      end

      it "raises errors for misaligned day_of_month values when changing interval" do
        expect {
          IceCube::Rule.daily.day_of_month(3, 6).interval(5)
        }.to raise_error(ArgumentError, "day_of_month can only be used with interval(1)")
      end
    end


  end
end
