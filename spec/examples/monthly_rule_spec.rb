require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe MonthlyRule do

    it 'should update previous interval' do
      schedule = stub(start_time: t0 = Time.utc(2013, 5, 17))
      rule = Rule.monthly(3)
      rule.interval(1)
      rule.next_time(t0 + 1, schedule, nil).should == t0 + 31.days
    end

    it 'should produce the correct number of days for @interval = 1' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.monthly
      #check assumption
      schedule.occurrences(t0 + 50 * ONE_DAY).size.should == 2
    end

    it 'should produce the correct number of days for @interval = 2' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.monthly(2)
      schedule.occurrences(t0 + 50 * ONE_DAY).size.should == 1
    end

    it 'should produce the correct number of days for @interval = 1 with only the 1st and 15th' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 1))
      schedule.add_recurrence_rule Rule.monthly.day_of_month(1, 15)
      #check assumption (1) (15) (1) (15)
      schedule.occurrences(t0 + 50 * ONE_DAY).map(&:day).should == [1, 15, 1, 15]
    end

    it 'should produce the correct number of days for @interval = 1 with only the 1st and last' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 1))
      schedule.add_recurrence_rule Rule.monthly.day_of_month(1, -1)
      #check assumption (1) (31) (1)
      schedule.occurrences(t0 + 60 * ONE_DAY).map(&:day).should == [1, 31, 1, 28, 1]
    end

    it 'should produce the correct number of days for @interval = 1 with only the first mondays' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 1))
      schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [1])
      #check assumption (month 1 monday) (month 2 monday)
      schedule.occurrences(t0 + 50 * ONE_DAY).size.should == 2
    end

    it 'should produce the correct number of days for @interval = 1 with only the last mondays' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 1))
      schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [-1])
      #check assumption (month 1 monday)
      schedule.occurrences(t0 + 40 * ONE_DAY).size.should == 1
    end

    it 'should produce the correct number of days for @interval = 1 with only the first and last mondays' do
      t0 = Time.utc(2010,  1,  1)
      t1 = Time.utc(2010, 12, 31)
      schedule = Schedule.new(t0)
      schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [1, -2])
      #check assumption (12 months - 2 dates each)
      schedule.occurrences(t1).size.should == 24
    end

    it 'should occur on every first day of a month at midnight and not skip months when DST ends' do
      [:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday].each_with_index do |weekday, wday|
        schedule = Schedule.new(t0 = Time.local(2011, 8, 1))
        schedule.add_recurrence_rule Rule.monthly.day_of_week(weekday => [1])
        last_date = nil
        schedule.first(48).each do |current_date|
          current_date.wday.should == wday
          current_date.hour.should == 0
          if last_date then
            month_interval = (current_date.year * 12 + current_date.month) -
                             (last_date.year * 12 + last_date.month)
            # should not skip months
            month_interval.should == 1
          end
          last_date = current_date
        end
      end
    end

    it 'should produce dates on a monthly interval for the last day of the month' do
      schedule = Schedule.new(t0 = Time.utc(2010, 3, 31, 0, 0, 0))
      schedule.add_recurrence_rule Rule.monthly
      schedule.first(10).should == [
        Time.utc(2010,  3, 31, 0, 0, 0), Time.utc(2010,  4, 30, 0, 0, 0),
        Time.utc(2010,  5, 31, 0, 0, 0), Time.utc(2010,  6, 30, 0, 0, 0),
        Time.utc(2010,  7, 31, 0, 0, 0), Time.utc(2010,  8, 31, 0, 0, 0),
        Time.utc(2010,  9, 30, 0, 0, 0), Time.utc(2010, 10, 31, 0, 0, 0),
        Time.utc(2010, 11, 30, 0, 0, 0), Time.utc(2010, 12, 31, 0, 0, 0)
      ]
    end

    it 'should produce dates on a monthly interval for latter days in the month near February' do
      schedule = Schedule.new(t0 = Time.utc(2010, 1, 29, 0, 0, 0))
      schedule.add_recurrence_rule Rule.monthly
      schedule.first(3).should == [
        Time.utc(2010, 1, 29, 0, 0, 0),
        Time.utc(2010, 2, 28, 0, 0, 0),
        Time.utc(2010, 3, 29, 0, 0, 0)
      ]
    end

    it 'should restrict to available days of month when specified' do
      schedule = Schedule.new(t0 = Time.utc(2013,1,31))
      schedule.add_recurrence_rule Rule.monthly.day_of_month(31)
      schedule.first(3).should == [
        Time.utc(2013, 1, 31),
        Time.utc(2013, 3, 31),
        Time.utc(2013, 5, 31)
      ]
    end

  end
end
