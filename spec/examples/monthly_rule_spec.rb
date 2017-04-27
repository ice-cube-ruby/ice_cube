require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe MonthlyRule, 'interval validation' do
    it 'converts a string integer to an actual int when using the interval method' do
      rule = Rule.monthly.interval("2")
      expect(rule.validations_for(:interval).first.interval).to eq(2)
    end

    it 'converts a string integer to an actual int when using the initializer' do
      rule = Rule.monthly("3")
      expect(rule.validations_for(:interval).first.interval).to eq(3)
    end

    it 'converts a string integer to an actual int' do
      rule = Rule.monthly("1")
      expect(rule.instance_variable_get(:@interval)).to eq(1)
    end

    it 'raises an argument error when a bad value is passed' do
      expect {
        rule = Rule.monthly("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
    end

    it 'raises an argument error when a bad value is passed using the interval method' do
      expect {
        rule = Rule.monthly.interval("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
    end
  end

  describe MonthlyRule do

    it 'should update previous interval' do
      t0 = Time.utc(2013, 5, 17)
      rule = Rule.monthly(3)
      rule.interval(1)
      expect(rule.next_time(t0 + 1, t0, nil)).to eq(t0 + (IceCube::ONE_DAY * 31))
    end

    it 'should produce the correct number of days for @interval = 1' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.monthly
      #check assumption
      expect(schedule.occurrences(t0 + 50 * ONE_DAY).size).to eq(2)
    end

    it 'should produce the correct number of days for @interval = 2' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.monthly(2)
      expect(schedule.occurrences(t0 + 50 * ONE_DAY).size).to eq(1)
    end

    it 'should produce the correct number of days for @interval = 1 with only the 1st and 15th' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 1))
      schedule.add_recurrence_rule Rule.monthly.day_of_month(1, 15)
      #check assumption (1) (15) (1) (15)
      expect(schedule.occurrences(t0 + 50 * ONE_DAY).map(&:day)).to eq([1, 15, 1, 15])
    end

    it 'should produce the correct number of days for @interval = 1 with only the 1st and last' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 1))
      schedule.add_recurrence_rule Rule.monthly.day_of_month(1, -1)
      #check assumption (1) (31) (1)
      expect(schedule.occurrences(t0 + 60 * ONE_DAY).map(&:day)).to eq([1, 31, 1, 28, 1])
    end

    it 'should produce the correct number of days for @interval = 1 with only the first mondays' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 1))
      schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [1])
      #check assumption (month 1 monday) (month 2 monday)
      expect(schedule.occurrences(t0 + 50 * ONE_DAY).size).to eq(2)
    end

    it 'should produce the correct number of days for @interval = 1 with only the last mondays' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 1))
      schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [-1])
      #check assumption (month 1 monday)
      expect(schedule.occurrences(t0 + 40 * ONE_DAY).size).to eq(1)
    end

    it 'should produce the correct number of days for @interval = 1 with only the first and last mondays' do
      t0 = Time.utc(2010,  1,  1)
      t1 = Time.utc(2010, 12, 31)
      schedule = Schedule.new(t0)
      schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [1, -2])
      #check assumption (12 months - 2 dates each)
      expect(schedule.occurrences(t1).size).to eq(24)
    end

    [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday].each_with_index do |weekday, wday|
      context "for every first #{weekday} of a month" do
        let(:schedule) {
          schedule = Schedule.new(t0 = Time.local(2011, 8, 1))
          schedule.add_recurrence_rule Rule.monthly.day_of_week(weekday => [1])
        }

        it "should not skip a month when DST ends" do
          schedule.first(48).inject(nil) do |last_date, current_date|
            next current_date unless last_date
            expect(month_interval(current_date, last_date)).to eq(1)
          end
        end

        it "should not change day when DST ends" do
          schedule.first(48).inject(nil) do |last_date, current_date|
            next current_date unless last_date
            expect(current_date.wday).to eq(wday)
          end
        end

        it "should not change hour when DST ends" do
          schedule.first(48).inject(nil) do |last_date, current_date|
            next current_date unless last_date
            expect(current_date.hour).to eq(0)
          end
        end
      end
    end

    it 'should produce dates on a monthly interval for the last day of the month' do
      schedule = Schedule.new(t0 = Time.utc(2010, 3, 31, 0, 0, 0))
      schedule.add_recurrence_rule Rule.monthly
      expect(schedule.first(10)).to eq([
        Time.utc(2010,  3, 31, 0, 0, 0), Time.utc(2010,  4, 30, 0, 0, 0),
        Time.utc(2010,  5, 31, 0, 0, 0), Time.utc(2010,  6, 30, 0, 0, 0),
        Time.utc(2010,  7, 31, 0, 0, 0), Time.utc(2010,  8, 31, 0, 0, 0),
        Time.utc(2010,  9, 30, 0, 0, 0), Time.utc(2010, 10, 31, 0, 0, 0),
        Time.utc(2010, 11, 30, 0, 0, 0), Time.utc(2010, 12, 31, 0, 0, 0)
      ])
    end

    it 'should produce dates on a monthly interval for latter days in the month near February' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 29, 0, 0, 0))
      schedule.add_recurrence_rule Rule.monthly
      expect(schedule.first(3)).to eq([
        Time.utc(2010, 1, 29, 0, 0, 0),
        Time.utc(2010, 2, 28, 0, 0, 0),
        Time.utc(2010, 3, 29, 0, 0, 0)
      ])
    end

    it 'should restrict to available days of month when specified' do
      schedule = Schedule.new(t0 = Time.utc(2013,1,31))
      schedule.add_recurrence_rule Rule.monthly.day_of_month(31)
      expect(schedule.first(3)).to eq([
        Time.utc(2013, 1, 31),
        Time.utc(2013, 3, 31),
        Time.utc(2013, 5, 31)
      ])
    end

    def month_interval(current_date, last_date)
      current_month = current_date.year * 12 + current_date.month
      last_month    = last_date.year * 12 + last_date.month
      current_month - last_month
    end

  end
end
