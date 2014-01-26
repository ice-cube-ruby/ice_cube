require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe MinutelyRule do

    it 'should update previous interval' do
      schedule = double(start_time: t0 = Time.now)
      rule = Rule.minutely(7)
      rule.interval(5)
      rule.next_time(t0 + 1, schedule, nil).should == t0 + 5 * IceCube::ONE_MINUTE
    end

    it 'should work across DST start hour' do
      std_end = Time.local(2013, 3, 10, 1, 59, 0)
      schedule = Schedule.new(std_end)
      schedule.add_recurrence_rule Rule.minutely
      schedule.first(3).should == [
        std_end,
        std_end + ONE_MINUTE,
        std_end + ONE_MINUTE * 2
      ]
    end

    it 'should not skip DST end hour' do
      std_start = Time.local(2013, 11, 3, 1, 0, 0)
      schedule = Schedule.new(std_start - 60)
      schedule.add_recurrence_rule Rule.minutely
      schedule.first(3).should == [
        std_start - ONE_MINUTE,
        std_start,
        std_start + ONE_MINUTE
      ]
    end

    it 'should produce the correct days for @interval = 3' do
      start_date = DAY
      schedule = Schedule.new(start_date)
      schedule = Schedule.from_yaml(schedule.to_yaml)
      schedule.add_recurrence_rule Rule.hourly(3)
      #check assumption (3) -- (1) 2 (3) 4 (5) 6
      dates = schedule.first(3)
      dates.size.should == 3
      dates.should == [DAY, DAY + 3 * ONE_HOUR, DAY + 6 * ONE_HOUR]
    end

    it 'should produce the correct minutes starting with an offset' do
      schedule = Schedule.new Time.new(2013, 11, 1, 1, 3, 0)
      schedule.rrule Rule.minutely(5)
      schedule.next_occurrence(Time.new(2013, 11, 1, 1, 4, 0)).should == Time.new(2013, 11, 1, 1, 8, 0)
    end

  end
end
