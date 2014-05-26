require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe HourlyRule do
    describe 'interval validation' do
      it 'converts a string integer to an actual int when using the interval method' do
        rule = Rule.hourly.interval("2")
        rule.validations_for(:interval).first.interval.should == 2
      end

      it 'converts a string integer to an actual int when using the initializer' do
        rule = Rule.hourly("3")
        rule.validations_for(:interval).first.interval.should == 3
      end

      it 'raises an argument error when a bad value is passed' do
        expect {
          rule = Rule.hourly("invalid")
        }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass an integer.")
      end

      it 'raises an argument error when a bad value is passed using the interval method' do
        expect {
          rule = Rule.hourly.interval("invalid")
        }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass an integer.")
      end
    end

    context :system_time_zone => 'America/Vancouver' do

      it 'should work across DST start hour' do
        schedule = Schedule.new(t0 = Time.local(2013, 3, 10, 1, 0, 0))
        schedule.add_recurrence_rule Rule.hourly
        schedule.first(3).should == [
          Time.local(2013, 3, 10, 1, 0, 0), # -0800
          Time.local(2013, 3, 10, 3, 0, 0), # -0700
          Time.local(2013, 3, 10, 4, 0, 0)  # -0700
        ]
      end

      it 'should not skip times in DST end hour' do
        schedule = Schedule.new(t0 = Time.local(2013, 11, 3, 0, 0, 0))
        schedule.add_recurrence_rule Rule.hourly
        schedule.first(4).should == [
          Time.local(2013, 11, 3, 0, 0, 0),             # -0700
          Time.local(2013, 11, 3, 1, 0, 0) - ONE_HOUR,  # -0700
          Time.local(2013, 11, 3, 1, 0, 0),             # -0800
          Time.local(2013, 11, 3, 2, 0, 0),             # -0800
        ]
      end

    end

    it 'should update previous interval' do
      schedule = double(start_time: t0 = Time.now)
      rule = Rule.hourly(7)
      rule.interval(5)
      rule.next_time(t0 + 1, schedule, nil).should == t0 + 5.hours
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

  end
end
