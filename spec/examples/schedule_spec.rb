require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::Schedule do

  include IceCube

  it 'yields itself for configuration' do
    t1 = Time.utc(2013, 2, 12, 12, 34 ,56)
    schedule = IceCube::Schedule.new do |s|
      s.start_time = t1
    end
    schedule.start_time.should == t1
  end

  it 'initializes with a start_time' do
    t1 = Time.local(2013, 2, 14, 0, 32, 0)
    schedule = IceCube::Schedule.new(t1)
    schedule.start_time.should be_a Time
    schedule.start_time.should == t1
  end

  it 'converts initialized DateTime to Time' do
    dt = DateTime.new(2013, 2, 14, 0, 32, 0)
    schedule = IceCube::Schedule.new(dt)
    schedule.start_time.should be_a Time
    schedule.start_time.should == Time.local(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec)
  end

  describe :duration do

    it 'should be based on end_time' do
      start = Time.now
      schedule = IceCube::Schedule.new(start)
      schedule.duration.should == 0
      schedule.end_time = start + 3600
      schedule.duration.should == 3600
    end

    it 'should give precedence to :end_time option' do
      start = Time.now
      conflicting_options = {:end_time => start + 600, :duration => 1200}
      schedule = IceCube::Schedule.new(start, conflicting_options)
      schedule.duration.should == 600
    end

  end

  describe :recurrence_times do

    it 'should start empty' do
      IceCube::Schedule.new.recurrence_times.should be_empty
    end

    it 'should include added times' do
      schedule = IceCube::Schedule.new(t0 = Time.now)
      schedule.add_recurrence_time(t1 = t0 + 3600)
      schedule.recurrence_times.should == [t1]
    end

    it 'can include start time' do
      schedule = IceCube::Schedule.new(t0 = Time.now)
      schedule.add_recurrence_time(t0)
      schedule.recurrence_times.should == [t0]
    end

  end

  describe :conflicts_with? do

    it 'should raise an error if both are not terminating' do
      schedules = 2.times.map do
        schedule = IceCube::Schedule.new(Time.now)
        schedule.rrule IceCube::Rule.daily
        schedule
      end
      lambda do
        schedules.first.conflicts_with?(schedules.last)
      end.should raise_error ArgumentError
    end

    it 'should not raise error if both are non-terminating closing time present' do
      schedule1 = IceCube::Schedule.new Time.now
      schedule1.rrule IceCube::Rule.weekly
      schedule2 = IceCube::Schedule.new Time.now
      schedule2.rrule IceCube::Rule.weekly
      lambda do
        schedule1.conflicts_with?(schedule2, Time.now + IceCube::ONE_DAY)
      end.should_not raise_error
    end

    it 'should not raise an error if one is non-terminating' do
      schedule1 = IceCube::Schedule.new Time.now
      schedule1.rrule IceCube::Rule.weekly
      schedule2 = IceCube::Schedule.new Time.now
      schedule2.rrule IceCube::Rule.weekly.until(Time.now)
      lambda do
        schedule1.conflicts_with?(schedule2)
      end.should_not raise_error
    end

    it 'should not raise an error if the other is non-terminating' do
      schedule1 = IceCube::Schedule.new Time.now
      schedule1.rrule IceCube::Rule.weekly.until(Time.now)
      schedule2 = IceCube::Schedule.new Time.now
      schedule2.rrule IceCube::Rule.weekly
      lambda do
        schedule1.conflicts_with?(schedule2)
      end.should_not raise_error
    end

    it 'should return true if conflict is present' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time)
      schedule1.rrule IceCube::Rule.daily
      schedule2 = IceCube::Schedule.new(start_time)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_DAY)
      conflict.should be_true
    end

    it 'should return false if conflict is not present' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time)
      schedule1.rrule IceCube::Rule.weekly.day(:tuesday)
      schedule2 = IceCube::Schedule.new(start_time)
      schedule2.rrule IceCube::Rule.weekly.day(:monday)
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_DAY)
      conflict.should be_false
    end

    it 'should return true if conflict is present based on duration' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_DAY + 1)
      schedule1.rrule IceCube::Rule.weekly.day(:monday)
      schedule2 = IceCube::Schedule.new(start_time)
      schedule2.rrule IceCube::Rule.weekly.day(:tuesday)
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_WEEK)
      conflict.should be_true
    end

    it 'should return true if conflict is present based on duration - other way' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time)
      schedule1.rrule IceCube::Rule.weekly.day(:tuesday)
      schedule2 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_DAY + 1)
      schedule2.rrule IceCube::Rule.weekly.day(:monday)
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_WEEK)
      conflict.should be_true
    end

    it 'should return false if conflict is past closing_time' do
      start_time = Time.local(2011, 1, 1, 12) # Sunday
      schedule1 = IceCube::Schedule.new(start_time)
      schedule1.rrule IceCube::Rule.weekly.day(:friday)
      schedule2 = IceCube::Schedule.new(start_time)
      schedule2.rrule IceCube::Rule.weekly.day(:friday)
      schedule2.conflicts_with?(schedule1, start_time + IceCube::ONE_WEEK).
        should be_true
      schedule2.conflicts_with?(schedule1, start_time + IceCube::ONE_DAY).
        should be_false
    end

    it 'should return false if conflict is not present based on duration' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.rrule IceCube::Rule.weekly.day(:monday)
      schedule2 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.weekly.day(:tuesday)
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_WEEK)
      conflict.should be_false
    end

    it 'should return false if conflict is not present on same day based on duration' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.rrule IceCube::Rule.daily
      schedule2 = IceCube::Schedule.new(start_time + 3600, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_WEEK)
      conflict.should be_false
    end

    it 'should return true if conflict is present on same day based on duration' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.rrule IceCube::Rule.daily
      schedule2 = IceCube::Schedule.new(start_time + 600, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_WEEK)
      conflict.should be_true
    end

    it 'should return true if conflict is present and no recurrence' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + 600, :duration => IceCube::ONE_HOUR)
      schedule2.add_recurrence_time(start_time + 600)
      conflict = schedule1.conflicts_with?(schedule2)
      conflict.should be_true
      conflict = schedule2.conflicts_with?(schedule1)
      conflict.should be_true
    end

    it 'should return false if conflict is not present and no recurrence' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + IceCube::ONE_HOUR, :duration => IceCube::ONE_HOUR)
      schedule2.add_recurrence_time(start_time + IceCube::ONE_HOUR)
      conflict = schedule1.conflicts_with?(schedule2)
      conflict.should be_false
      conflict = schedule2.conflicts_with?(schedule1)
      conflict.should be_false
    end

    it 'should return false if conflict is not present and single recurrence' do
       start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + IceCube::ONE_HOUR, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2)
      conflict.should be_false
      conflict = schedule2.conflicts_with?(schedule1)
      conflict.should be_false
    end

   it 'should return true if conflict is present and single recurrence' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + 600, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2)
      conflict.should be_true
      conflict = schedule2.conflicts_with?(schedule1)
      conflict.should be_true
    end

    it 'should return false if conflict is not present and single recurrence and time originally specified as Time' do
      start_time = Time.local(2020, 9, 21, 11, 30, 0)
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + IceCube::ONE_HOUR, :duration => IceCube::ONE_HOUR)
      schedule2.add_recurrence_time(start_time + IceCube::ONE_HOUR)
      conflict = schedule1.conflicts_with?(schedule2)
      conflict.should be_false
      conflict = schedule2.conflicts_with?(schedule1)
      conflict.should be_false
    end

  end

  describe :each do

    it 'should be able to yield occurrences for a schedule' do
      schedule = IceCube::Schedule.new
      schedule.add_recurrence_rule IceCube::Rule.daily
      i = 0
      answers = []
      schedule.each_occurrence do |time|
        answers << time
        i += 1
        break if i > 9
      end
      answers.should == schedule.first(10)
    end

    it 'should return self' do
      schedule = IceCube::Schedule.new
      schedule.each_occurrence { |s| }.should == schedule
    end

    it 'should stop itself when hitting the end of a schedule' do
      schedule = IceCube::Schedule.new(t0 = Time.now)
      t1 = t0 + 24 * IceCube::ONE_DAY
      schedule.add_recurrence_time t1
      answers = []
      schedule.each_occurrence { |t| answers << t }
      answers.should == [t0, t1]
    end

  end

  describe :all_occurrences_enumerator do
    it 'should be equivalent to all_occurrences in terms of arrays' do
      schedule = IceCube::Schedule.new(Time.now, :duration => IceCube::ONE_HOUR)
      schedule.add_recurrence_rule IceCube::Rule.daily.until(Time.now + 3 * IceCube::ONE_DAY)
      schedule.all_occurrences == schedule.all_occurrences_enumerator.to_a 
    end
  end

  describe :remaining_occurrences_enumerator do
    it 'should be equivalent to remaining_occurrences in terms of arrays' do
      schedule = IceCube::Schedule.new(Time.now, :duration => IceCube::ONE_HOUR)
      schedule.add_recurrence_rule IceCube::Rule.daily.until(Time.now + 3 * IceCube::ONE_DAY)
      schedule.remaining_occurrences == schedule.remaining_occurrences_enumerator.to_a 
    end
  end

  describe :all_occurrences do

    it 'has end times for each occurrence' do
      schedule = IceCube::Schedule.new(Time.now, :duration => IceCube::ONE_HOUR)
      schedule.add_recurrence_rule IceCube::Rule.daily.until(Time.now + 3 * IceCube::ONE_DAY)
      schedule.all_occurrences.all? { |o| o.end_time.should == o + IceCube::ONE_HOUR }
    end

    it 'should include its start time when empty' do
      schedule = IceCube::Schedule.new(t0 = Time.now)
      schedule.all_occurrences.should == [t0]
    end

   it 'should have one occurrence with one recurrence time at start_time' do
      schedule = IceCube::Schedule.new(t0 = Time.local(2012, 12, 12, 12, 12, 12))
      schedule.add_recurrence_time t0
      schedule.all_occurrences.should == [t0]
    end

    it 'should have two occurrences with a recurrence time after start_time' do
      schedule = IceCube::Schedule.new(t0 = Time.local(2012, 12, 12, 12, 12, 12))
      schedule.add_recurrence_time t1 = Time.local(2013,  1, 13,  1, 13,  1)
      schedule.all_occurrences.should == [t0, t1]
    end

    it 'should return an error if there is nothing to stop it' do
      schedule = IceCube::Schedule.new
      schedule.rrule IceCube::Rule.daily
      lambda do
        schedule.all_occurrences
      end.should raise_error ArgumentError
    end

    it 'should consider count limits separately for multiple rules' do
      schedule = IceCube::Schedule.new
      schedule.rrule IceCube::Rule.minutely.count(3)
      schedule.rrule IceCube::Rule.daily.count(3)
      schedule.all_occurrences.size.should == 5
    end

  end

  describe :next_occurrences do

    let(:nonsense) { IceCube::Rule.monthly.day_of_week(:monday => [1]).day_of_month(31) }

    it 'should be able to calculate next occurrences ignoring excluded times' do
      start_time = Time.now
      schedule = IceCube::Schedule.new start_time
      schedule.rrule IceCube::Rule.daily(1)
      schedule.extime start_time + IceCube::ONE_DAY
      occurrences = schedule.next_occurrences(2, start_time) # 3 occurrences in the next year
      occurrences.should == [
        start_time + IceCube::ONE_DAY * 2,
        start_time + IceCube::ONE_DAY * 3
      ]
    end

    it 'should be empty if nothing is found before closing time' do
      schedule = IceCube::Schedule.new(t0 = Time.utc(2013, 1, 1)) do |s|
        next_year = Date.new(t0.year + 1, t0.month, t0.day)
        s.add_recurrence_rule nonsense.until(next_year)
      end
      trap_infinite_loop_beyond(24)
      schedule.next_occurrences(1).should be_empty
    end

  end

  describe :next_occurrence do

    it 'should be able to calculate the next occurrence past an exception time' do
      start_time = Time.now
      schedule = IceCube::Schedule.new start_time
      schedule.rrule IceCube::Rule.daily(1)
      schedule.extime start_time + IceCube::ONE_DAY
      occurrence = schedule.next_occurrence(start_time) # 3 occurrences in the next year
      occurrence.should == start_time + IceCube::ONE_DAY * 2
    end

    it 'should respect time zone info for a local future time [#115]' do
      start_time = Time.local(Time.now.year + 1, 7, 1, 0, 0, 0)
      compare_time_zone_info(start_time)
    end

    it 'should respect time zone info for a local past time [#115]' do
      start_time = Time.local(Time.now.year - 1, 7, 1, 0, 0, 0)
      compare_time_zone_info(start_time)
    end

    it 'should respect time zone info for a utc past time [#115]' do
      start_time = Time.utc(Time.now.year - 1, 7, 1, 0, 0, 0)
      compare_time_zone_info(start_time)
    end

    it 'should respect time zone info for a utc future time [#115]' do
      start_time = Time.utc(Time.now.year + 1, 7, 1, 0, 0, 0)
      compare_time_zone_info(start_time)
    end

    it 'should respect time zone info for a offset past time [#115]' do
      start_time = Time.utc(Time.now.year - 1, 7, 1, 0, 0, 0).localtime("-05:00")
      compare_time_zone_info(start_time)
    end

    it 'should respect time zone info for a offset future time [#115]' do
      start_time = Time.utc(Time.now.year + 1, 7, 1, 0, 0, 0).localtime("-05:00")
      compare_time_zone_info(start_time)
    end

  end

  describe :previous_occurrence do

    it 'returns the previous occurrence for a time in the schedule' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrence(t0 + 2 * ONE_DAY)
      previous.should == t0 + ONE_DAY
    end

    it 'returns nil given the start time' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrence(t0)
      previous.should be_nil
    end

  end

  describe :previous_occurrences do

    it 'returns an array of previous occurrences from a given time' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrences(2, t0 + 3 * ONE_DAY)
      previous.should == [t0 + ONE_DAY, t0 + 2 * ONE_DAY]
    end

    it 'limits the returned occurrences to a given count' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrences(999, t0 + 2 * ONE_DAY)
      previous.should == [t0, t0 + ONE_DAY]
    end

    it 'returns empty array given the start time' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrences(2, t0)
      previous.should == []
    end

  end

  describe :last do

    it 'returns the last occurrence for a terminating schedule' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      t1 = Time.utc(2013, 5, 31, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily.until(t1 + 1)
      schedule.last.should == t1
    end

    it 'returns an array of occurrences given a number' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      t1 = Time.utc(2013, 5, 31, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily.until(t1 + 1)
      schedule.last(2).should == [t1 - ONE_DAY, t1]
    end

    it 'raises an error for a non-terminating schedule' do
      schedule = IceCube::Schedule.new
      schedule.add_recurrence_rule IceCube::Rule.daily
      expect { schedule.last }.to raise_error
    end

  end

  describe :start_date= do

    it 'should modify start date in rrule_occurrence_heads when changed' do
      schedule = IceCube::Schedule.new(Time.now - 1000)
      schedule.rrule IceCube::Rule.daily
      schedule.start_time = (start_date = Time.now)
      (Time.now - schedule.first.start_time).should be < 100
    end

  end

  describe :recurrence_rules do

    it 'should not include rules for single occurrences' do
      schedule = IceCube::Schedule.new Time.now
      schedule.add_recurrence_time Time.now
      schedule.rrules.should be_empty
    end

  end

  describe :remove_recurrence_rule do

    it 'should be able to one rule based on the comparator' do
      schedule = IceCube::Schedule.new Time.now
      schedule.rrule IceCube::Rule.daily
      schedule.rrule IceCube::Rule.daily(2)
      schedule.remove_recurrence_rule schedule.rrules.first
      schedule.rrules.count.should == 1
    end

    it 'should be able to remove multiple rules based on the comparator' do
      schedule = IceCube::Schedule.new Time.now
      schedule.rrule IceCube::Rule.daily
      schedule.rrule IceCube::Rule.daily
      schedule.remove_recurrence_rule schedule.rrules.first
      schedule.rrules.should be_empty
    end

    it 'should return the rule that was removed' do
      schedule = IceCube::Schedule.new Time.now
      rule = IceCube::Rule.daily
      schedule.rrule rule
      rule2 = schedule.remove_recurrence_rule rule
      [rule].should == rule2
    end

    it 'should return [] if nothing was removed' do
      schedule = IceCube::Schedule.new Time.now
      rule = IceCube::Rule.daily
      schedule.remove_recurrence_rule(rule).should == []
    end

  end

  describe :remove_exception_rule do

    it 'should be able to one rule based on the comparator' do
      schedule = IceCube::Schedule.new Time.now
      schedule.exrule IceCube::Rule.daily
      schedule.exrule IceCube::Rule.daily(2)
      schedule.remove_exception_rule schedule.exrules.first
      schedule.exrules.count.should == 1
    end

    it 'should be able to remove multiple rules based on the comparator' do
      schedule = IceCube::Schedule.new Time.now
      schedule.exrule IceCube::Rule.daily
      schedule.exrule IceCube::Rule.daily
      schedule.remove_exception_rule schedule.exrules.first
      schedule.exrules.should be_empty
    end

    it 'should return the rule that was removed' do
      schedule = IceCube::Schedule.new Time.now
      rule = IceCube::Rule.daily
      schedule.exrule rule
      rule2 = schedule.remove_exception_rule rule
      [rule].should == rule2
    end

    it 'should return [] if nothing was removed' do
      schedule = IceCube::Schedule.new Time.now
      rule = IceCube::Rule.daily
      schedule.remove_exception_rule(rule).should == []
    end

  end

  describe :remove_recurrence_time do

    it 'should be able to remove a recurrence date from a schedule' do
      time = Time.now
      schedule = IceCube::Schedule.new(time)
      schedule.add_recurrence_time time
      schedule.remove_recurrence_time time
      schedule.recurrence_times.should be_empty
    end

    it 'should return the time that was removed' do
      schedule = IceCube::Schedule.new Time.now
      time = Time.now
      schedule.rtime time
      schedule.remove_rtime(time).should == time
    end

    it 'should return nil if the date was not in the schedule' do
      schedule = IceCube::Schedule.new Time.now
      schedule.remove_recurrence_time(Time.now).should be_nil
    end

  end

  describe :remove_exception_time do

    it 'should be able to remove a exception date from a schedule' do
      time = Time.now
      schedule = IceCube::Schedule.new(time)
      schedule.extime time
      schedule.remove_exception_time time
      schedule.exception_times.should be_empty
    end

    it 'should return the date that was removed' do
      schedule = IceCube::Schedule.new Time.now
      time = Time.now
      schedule.extime time
      schedule.remove_extime(time).should == time
    end

    it 'should return nil if the date was not in the schedule' do
      schedule = IceCube::Schedule.new Time.now
      schedule.remove_exception_time(Time.now).should be_nil
    end

  end

  describe :occurs_on? do

    subject(:schedule) { IceCube::Schedule.new(start_time) }

    shared_examples "occurring on a given day" do
      WORLD_TIME_ZONES.each do |zone|
        context "in #{zone}", :system_time_zone => zone do
          specify 'should determine if it occurs on a given Date' do
            schedule.occurs_on?(Date.new(2010, 7, 1)).should be_false
            schedule.occurs_on?(Date.new(2010, 7, 2)).should be_true
            schedule.occurs_on?(Date.new(2010, 7, 3)).should be_false
          end

          specify 'should determine if it occurs on the day of a given UTC Time' do
            schedule.occurs_on?(Time.utc(2010, 7, 1, 23, 59, 59)).should be_false
            schedule.occurs_on?(Time.utc(2010, 7, 2,  0,  0,  1)).should be_true
            schedule.occurs_on?(Time.utc(2010, 7, 2, 23, 59, 59)).should be_true
            schedule.occurs_on?(Time.utc(2010, 7, 3,  0,  0,  1)).should be_false
          end

          specify 'should determine if it occurs on the day of a given local Time' do
            schedule.occurs_on?(Time.local(2010, 7, 1, 23, 59, 59)).should be_false
            schedule.occurs_on?(Time.local(2010, 7, 2,  0,  0,  1)).should be_true
            schedule.occurs_on?(Time.local(2010, 7, 2, 23, 59, 59)).should be_true
            schedule.occurs_on?(Time.local(2010, 7, 3,  0,  0,  1)).should be_false
          end

          specify 'should determine if it occurs on the day of a given non-local Time' do
            schedule.occurs_on?(Time.new(2010, 7, 1, 23, 59, 59, "+11:15")).should be_false
            schedule.occurs_on?(Time.new(2010, 7, 2,  0,  0,  1, "+11:15")).should be_true
            schedule.occurs_on?(Time.new(2010, 7, 2, 23, 59, 59, "+11:15")).should be_true
            schedule.occurs_on?(Time.new(2010, 7, 3,  0,  0,  1, "+11:15")).should be_false
          end

          specify 'should determine if it occurs on the day of a given ActiveSupport::Time', :if_active_support_time => true do
            Time.zone = "Pacific/Honolulu"
            schedule.occurs_on?(Time.zone.parse('2010-07-01 23:59:59')).should be_false
            schedule.occurs_on?(Time.zone.parse('2010-07-02 00:00:01')).should be_true
            schedule.occurs_on?(Time.zone.parse('2010-07-02 23:59:59')).should be_true
            schedule.occurs_on?(Time.zone.parse('2010-07-03 00:00:01')).should be_false
          end
        end
      end
    end

    shared_examples :occurs_on? do
      context 'starting from a UTC Time' do
        let(:start_time) { Time.utc(2010, 7, 2, 10, 0, 0) }
        include_examples "occurring on a given day"
      end

      context 'starting from a local Time' do
        let(:start_time) { Time.local(2010, 7, 2, 10, 0, 0) }
        include_examples "occurring on a given day"
      end

      context 'starting from a non-local Time' do
        let(:start_time) { Time.local(2010, 7, 2, 10, 0, 0, false, "-2:30") }
        include_examples 'occurring on a given day'
      end

      context 'starting from an ActiveSupport::Time', :if_active_support_time => true do
        let(:start_time) { Time.new(2010, 7, 2, 10, 0, 0, '-07:00').in_time_zone('America/Vancouver') }
        include_examples 'occurring on a given day'
      end
    end

    context 'with a recurrence rule limited by count' do
      before { schedule.add_recurrence_rule IceCube::Rule.daily.count(1) }
      include_examples :occurs_on?
    end

    context 'with a recurrence rule limited by until' do
      before { schedule.add_recurrence_rule IceCube::Rule.daily.until(start_time) }
      include_examples :occurs_on?
    end

    context 'with a single recurrence time' do
      before { schedule.add_recurrence_time(start_time) }
      include_examples :occurs_on?
    end

    it 'should be true for multiple rtimes' do
      schedule = IceCube::Schedule.new(Time.local(2010, 7, 10, 16))
      schedule.add_recurrence_time(Time.local(2010, 7, 11, 16))
      schedule.add_recurrence_time(Time.local(2010, 7, 12, 16))
      schedule.add_recurrence_time(Time.local(2010, 7, 13, 16))

      schedule.occurs_on?(Date.new(2010, 7, 11)).should be_true
      schedule.occurs_on?(Date.new(2010, 7, 12)).should be_true
      schedule.occurs_on?(Date.new(2010, 7, 13)).should be_true
    end

  end

  def compare_time_zone_info(start_time)
    schedule = IceCube::Schedule.new(start_time)
    schedule.rrule IceCube::Rule.yearly(1)
    occurrence = schedule.next_occurrence

    occurrence.dst?.should == start_time.dst? if start_time.respond_to? :dst?
    occurrence.utc?.should == start_time.utc? if start_time.respond_to? :utc?
    occurrence.zone.should == start_time.zone
    occurrence.utc_offset == start_time.utc_offset
  end

  def trap_infinite_loop_beyond(iterations)
    IceCube::ValidatedRule.any_instance.should_receive(:finds_acceptable_time?).
                          at_most(iterations).times.and_call_original
  end
end
