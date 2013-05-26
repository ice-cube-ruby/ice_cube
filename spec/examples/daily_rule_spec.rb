require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe DailyRule, 'occurs_on?' do

    context :system_time_zone => 'America/Vancouver' do

      it 'should include nearest time in DST start hour' do
        schedule = Schedule.new(t0 = Time.local(2013, 3, 9, 2, 30, 0))
        schedule.add_recurrence_rule Rule.daily
        schedule.first(3).should == [
          Time.local(2013, 3,  9, 2, 30, 0), # -0800
          Time.local(2013, 3, 10, 3, 30, 0), # -0700
          Time.local(2013, 3, 11, 2, 30, 0)  # -0700
        ]
      end

      it 'should not skip times in DST end hour' do
        schedule = Schedule.new(t0 = Time.local(2013, 11, 2, 2, 30, 0))
        schedule.add_recurrence_rule Rule.daily
        schedule.first(3).should == [
          Time.local(2013, 11, 2, 2, 30, 0), # -0700
          Time.local(2013, 11, 3, 2, 30, 0), # -0800
          Time.local(2013, 11, 4, 2, 30, 0)  # -0800
        ]
      end

      it 'should include nearest time to DST start when locking hour_of_day' do
        schedule = Schedule.new(t0 = Time.local(2013, 3, 9, 2, 0, 0))
        schedule.add_recurrence_rule Rule.daily.hour_of_day(2)
        schedule.first(3).should == [
          Time.local(2013, 3,  9, 2, 0, 0), # -0800
          Time.local(2013, 3, 10, 3, 0, 0), # -0700
          Time.local(2013, 3, 11, 2, 0, 0)  # -0700
        ]
      end

    end

    it 'should update previous interval' do
      schedule = stub(start_time: t0 = Time.now)
      rule = Rule.daily(7)
      rule.interval(5)
      rule.next_time(t0 + 1, schedule, nil).should == t0 + 5 * ONE_DAY
    end

    it 'should produce the correct days for @interval = 1' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.daily
      #check assumption
      times = schedule.occurrences(t0 + 2 * ONE_DAY)
      times.size.should == 3
      times.should == [t0, t0 + ONE_DAY, t0 + 2 * ONE_DAY]
    end

    it 'should produce the correct days for @interval = 2' do
      schedule = Schedule.new(t0 = Time.now)
      schedule.add_recurrence_rule Rule.daily(2)
      #check assumption (3) -- (1) 2 (3) 4 (5) 6
      times = schedule.occurrences(t0 + 5 * ONE_DAY)
      times.size.should == 3
      times.should == [t0, t0 + 2 * ONE_DAY, t0 + 4 * ONE_DAY]
    end

    it 'should produce the correct days for @interval = 2 when crossing into a new year' do
      schedule = Schedule.new(t0 = Time.utc(2011, 12, 29))
      schedule.add_recurrence_rule Rule.daily(2)
      #check assumption (3) -- (1) 2 (3) 4 (5) 6
      times = schedule.occurrences(t0 + 5 * ONE_DAY)
      times.size.should == 3
      times.should == [t0, t0 + 2 * ONE_DAY, t0 + 4 * ONE_DAY]
    end

    it 'should produce the correct days for interval of 4 day with hour and minute of day set' do
      schedule = Schedule.new(t0 = Time.local(2010, 3, 1))
      schedule.add_recurrence_rule Rule.daily(4).hour_of_day(5).minute_of_hour(45)
      #check assumption 2 -- 1 (2) (3) (4) 5 (6)
      times = schedule.occurrences(t0 + 5 * ONE_DAY)
      times.should == [
        t0 + 5 * ONE_HOUR + 45 * ONE_MINUTE,
        t0 + 4 * ONE_DAY + 5 * ONE_HOUR + 45 * ONE_MINUTE
      ]
    end

  end
end
