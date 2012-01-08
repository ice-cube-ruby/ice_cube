require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::Schedule do

  include IceCube

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
      schedule.each_occurrence { |s| break }.should == schedule
    end

    it 'should stop itself when hitting the end of a schedule' do
      time = Time.now + 24 * ONE_DAY
      schedule = IceCube::Schedule.new
      schedule.add_recurrence_time time
      answers = []
      schedule.each_occurrence { |t| answers << t }
      answers.should == [time]
    end

  end

  describe :all_occurrences do

    it 'should stop automatically with just a date' do
      time = Time.now + 24 * ONE_DAY
      schedule = IceCube::Schedule.new
      schedule.add_recurrence_time time
      schedule.all_occurrences.should == [time]
    end

    it 'should return an error if there is nothing to stop it' do
      schedule = IceCube::Schedule.new
      schedule.rrule IceCube::Rule.daily
      lambda do
        schedule.all_occurrences
      end.should raise_error ArgumentError
    end

  end

  describe :next_occurrences do

    it 'should be able to calculate next occurrences ignoring exclude_dates' do
      start_time = Time.now
      schedule = Schedule.new start_time
      schedule.rrule Rule.daily(1)
      schedule.exdate start_time + ONE_DAY
      occurrences = schedule.next_occurrences(2, start_time) # 3 occurrences in the next year
      occurrences.should == [
        start_time + ONE_DAY * 2,
        start_time + ONE_DAY * 3
      ]
    end

  end

  describe :next_occurrence do

    it 'should be able to calculate the next occurrence past an exdate' do
      start_time = Time.now
      schedule = Schedule.new start_time
      schedule.rrule Rule.daily(1)
      schedule.exdate start_time + ONE_DAY
      occurrence = schedule.next_occurrence(start_time) # 3 occurrences in the next year
      occurrence.should == start_time + ONE_DAY * 2
    end

  end

  describe :start_date= do

    it 'should modify start date in rrule_occurrence_heads when changed' do
      schedule = Schedule.new (Time.now - 1000)
      schedule.rrule Rule.daily
      schedule.start_date = (start_date = Time.now)
      (Time.now - schedule.first).should be < 100
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

  describe :remove_recurrence_date do

    it 'should be able to remove a recurrence date from a schedule' do
      time = Time.now
      schedule = IceCube::Schedule.new(time)
      schedule.add_recurrence_date time
      schedule.remove_recurrence_date time
      schedule.recurrence_dates.should be_empty
    end

    it 'should return the date that was removed' do
      schedule = IceCube::Schedule.new Time.now
      time = Time.now
      schedule.rdate time
      schedule.remove_rdate(time).should == time
    end

    it 'should return nil if the date was not in the schedule' do
      schedule = IceCube::Schedule.new Time.now
      schedule.remove_recurrence_date(Time.now).should be_nil
    end

  end

  describe :remove_exception_date do

    it 'should be able to remove a exception date from a schedule' do
      time = Time.now
      schedule = IceCube::Schedule.new(time)
      schedule.exdate time
      schedule.remove_exception_date time
      schedule.exception_dates.should be_empty
    end

    it 'should return the date that was removed' do
      schedule = IceCube::Schedule.new Time.now
      time = Time.now
      schedule.exdate time
      schedule.remove_exdate(time).should == time
    end

    it 'should return nil if the date was not in the schedule' do
      schedule = IceCube::Schedule.new Time.now
      schedule.remove_exception_date(Time.now).should be_nil
    end

  end

end
