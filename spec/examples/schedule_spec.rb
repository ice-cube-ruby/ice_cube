require File.dirname(__FILE__) + '/spec_helper'

describe IceCube::Schedule do

  include IceCube

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
      schedule.instance_variable_get(:@rrule_occurrence_heads).each do |rrule|
        rrule.instance_variable_get(:@start_date).should == start_date
      end
    end

    it 'should modify start date in exrule_occurrence_heads when changed' do
      schedule = Schedule.new (Time.now - 1000)
      schedule.exrule Rule.daily
      schedule.start_date = (start_date = Time.now)
      schedule.instance_variable_get(:@exrule_occurrence_heads).each do |rrule|
        rrule.instance_variable_get(:@start_date).should == start_date
      end
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
