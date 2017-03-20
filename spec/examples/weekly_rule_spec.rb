require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe WeeklyRule, 'interval validation' do
    it 'converts a string integer to an actual int when using the interval method' do
      rule = Rule.weekly.interval("2")
      expect(rule.validations_for(:interval).first.interval).to eq(2)
    end

    it 'converts a string integer to an actual int when using the initializer' do
      rule = Rule.weekly("3")
      expect(rule.validations_for(:interval).first.interval).to eq(3)
    end

    it 'raises an argument error when a bad value is passed' do
      expect {
        rule = Rule.weekly("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass an integer.")
    end

    it 'raises an argument error when a bad value is passed using the interval method' do
      expect {
        rule = Rule.weekly.interval("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass an integer.")
    end
  end

  describe WeeklyRule do

    context 'in Vancouver time', :system_time_zone => 'America/Vancouver' do

      it 'should include nearest time in DST start hour' do
        schedule = Schedule.new(t0 = Time.local(2013, 3, 3, 2, 30, 0))
        schedule.add_recurrence_rule Rule.weekly
        expect(schedule.first(3)).to eq([
          Time.local(2013, 3,  3, 2, 30, 0), # -0800
          Time.local(2013, 3, 10, 3, 30, 0), # -0700
          Time.local(2013, 3, 17, 2, 30, 0)  # -0700
        ])
      end

      it 'should not skip times in DST end hour' do
        schedule = Schedule.new(t0 = Time.local(2013, 10, 27, 2, 30, 0))
        schedule.add_recurrence_rule Rule.weekly
        expect(schedule.first(3)).to eq([
          Time.local(2013, 10, 27, 2, 30, 0), # -0700
          Time.local(2013, 11,  3, 2, 30, 0), # -0700
          Time.local(2013, 11, 10, 2, 30, 0)  # -0800
        ])
      end

    end

    it 'should update previous interval' do
      t0 = Time.new(2013, 1, 1)
      rule = Rule.weekly(7)
      rule.interval(2)
      expect(rule.next_time(t0 + 1, t0, nil)).to eq(t0 + 2 * ONE_WEEK)
    end

    it 'should produce the correct number of days for @interval = 1 with no weekdays specified' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.weekly
      #check assumption (2 weeks in the future) (1) (2) (3) (4) (5)
      times = schedule.occurrences(t0 + (7 * 3 + 1) * ONE_DAY)
      expect(times.size).to eq(4)
    end

    it 'should produce the correct number of days for @interval = 1 with only weekends' do
      schedule = Schedule.new(t0 = WEDNESDAY)
      schedule.add_recurrence_rule Rule.weekly.day(:saturday, :sunday)
      #check assumption
      expect(schedule.occurrences(t0 + 4 * ONE_WEEK).size).to eq(8)
    end

    it 'should set days from symbol args' do
      schedule = Schedule.new(t0 = WEDNESDAY)
      schedule.add_recurrence_rule Rule.weekly.day(:monday, :wednesday)
      expect(schedule.rrules.first.validations_for(:day).map(&:day)).to eq([1, 3])
    end

    it 'should set days from array of symbols' do
      schedule = Schedule.new(t0 = WEDNESDAY)
      schedule.add_recurrence_rule Rule.weekly.day([:monday, :wednesday])
      expect(schedule.rrules.first.validations_for(:day).map(&:day)).to eq([1, 3])
    end

    it 'should set days from integer args' do
      schedule = Schedule.new(t0 = WEDNESDAY)
      schedule.add_recurrence_rule Rule.weekly.day(1, 3)
      expect(schedule.rrules.first.validations_for(:day).map(&:day)).to eq([1, 3])
    end

    it 'should set days from array of integers' do
      schedule = Schedule.new(t0 = WEDNESDAY)
      schedule.add_recurrence_rule Rule.weekly.day([1, 3])
      expect(schedule.rrules.first.validations_for(:day).map(&:day)).to eq([1, 3])
    end

    it 'should raise an error on invalid input' do
      schedule = Schedule.new(t0 = WEDNESDAY)
      expect { schedule.add_recurrence_rule Rule.weekly.day(["1", "3"]) }.to raise_error(ArgumentError)
    end

    it 'should ignore weekday validation when no days are specified' do
      schedule = Schedule.new(t0 = WEDNESDAY)
      schedule.add_recurrence_rule Rule.weekly(2).day([])

      times = schedule.occurrences(t0 + 3 * ONE_WEEK)
      expect(times).to eq [t0, t0 + 2 * ONE_WEEK]
    end

    it 'should produce the correct number of days for @interval = 2 with only one day per week' do
      schedule = Schedule.new(t0 = WEDNESDAY)
      schedule.add_recurrence_rule Rule.weekly(2).day(:wednesday)
      #check assumption
      times = schedule.occurrences(t0 + 3 * ONE_WEEK)
      expect(times).to eq([t0, t0 + 2 * ONE_WEEK])
    end

    it 'should produce the correct days for @interval = 2, regardless of the start week' do
      schedule = Schedule.new(t0 = WEDNESDAY + ONE_WEEK)
      schedule.add_recurrence_rule Rule.weekly(2).day(:wednesday)
      #check assumption
      times = schedule.occurrences(t0 + 3 * ONE_WEEK)
      expect(times).to eq([t0, t0 + 2 * ONE_WEEK])
    end

    it 'should occur every 2nd tuesday of a month' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.monthly.hour_of_day(11).day_of_week(:tuesday => [2])
      schedule.first(48).each do |d|
        expect(d.hour).to eq(11)
        expect(d.wday).to eq(2)
      end
    end

    it 'should be able to start on sunday but repeat on wednesdays' do
      schedule = Schedule.new(t0 = Time.local(2010, 8, 1))
      schedule.add_recurrence_rule Rule.weekly.day(:monday)
      expect(schedule.first(3)).to eq([
        Time.local(2010, 8,  2),
        Time.local(2010, 8,  9),
        Time.local(2010, 8, 16)
      ])
    end

    it 'should start weekly rules on monday when monday is the week start' do
      schedule = Schedule.new(t0 = Time.local(2012, 2, 7))
      schedule.add_recurrence_rule Rule.weekly(2, :monday).day(:tuesday, :sunday)
      expect(schedule.first(3)).to eq([
        Time.local(2012, 2,  7),
        Time.local(2012, 2, 12),
        Time.local(2012, 2, 21)
      ])
    end

    it 'should start weekly rules on sunday by default' do
      schedule = Schedule.new(t0 = Time.local(2012,2,7))
      schedule.add_recurrence_rule Rule.weekly(2).day(:tuesday, :sunday)
      expect(schedule.first(3)).to eq([
        Time.local(2012, 2,  7),
        Time.local(2012, 2, 19),
        Time.local(2012, 2, 21)
      ])
    end

    it 'should find the next date on a biweekly sunday searching from a few days before the date' do
      t0 = Time.utc(2017, 1, 15, 9, 0, 0)
      t1 = Time.utc(2017, 1, 24)
      t2 = t0 + (2 * ONE_WEEK)
      schedule = Schedule.new(t0, :duration => IceCube::ONE_HOUR)
      schedule.add_recurrence_rule Rule.weekly(2, :sunday).day(:sunday)
      t3 = schedule.next_occurrence(t1, :spans => true)
      expect(t3).to eq(t2)
    end

    it 'should validate week_start input' do
      expect { Rule.weekly(2, :someday) }.to raise_error(ArgumentError)
    end

  end
end
