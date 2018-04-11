require File.dirname(__FILE__) + '/../spec_helper'
require 'benchmark'

describe IceCube::Schedule do

  include IceCube

  it 'yields itself for configuration' do
    t1 = Time.utc(2013, 2, 12, 12, 34 ,56)
    schedule = IceCube::Schedule.new do |s|
      s.start_time = t1
    end
    expect(schedule.start_time).to eq(t1)
  end

  it 'initializes with a start_time' do
    t1 = Time.local(2013, 2, 14, 0, 32, 0)
    schedule = IceCube::Schedule.new(t1)
    expect(schedule.start_time).to be_a Time
    expect(schedule.start_time).to eq(t1)
  end

  it 'converts initialized DateTime to Time', expect_warnings: true do
    dt = DateTime.new(2013, 2, 14, 0, 32, 0)
    schedule = IceCube::Schedule.new(dt)
    expect(schedule.start_time).to be_a Time
    expect(schedule.start_time).to eq(Time.local(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec))
  end

  describe :next_occurrence do

    it 'should not raise an exception when calling next occurrence with no remaining occurrences' do
      schedule = IceCube::Schedule.new Time.now
      expect { schedule.next_occurrence }.not_to raise_error
    end

    it "should not skip ahead a day when called with a date" do
      schedule = IceCube::Schedule.new(Time.utc(2014, 1, 1, 12, 34, 56)) do |s|
        s.add_recurrence_rule IceCube::Rule.hourly
      end
      next_hour = schedule.next_occurrence(Date.new(2014, 1, 2))
      expect( next_hour ).to eq Time.utc(2014, 1, 2, 00, 34 , 56)
    end

  end

  describe :duration do

    it 'should be based on end_time' do
      start = Time.now
      schedule = IceCube::Schedule.new(start)
      expect(schedule.duration).to eq(0)
      schedule.end_time = start + 3600
      expect(schedule.duration).to eq(3600)
    end

    it 'should give precedence to :end_time option' do
      start = Time.now
      conflicting_options = {:end_time => start + 600, :duration => 1200}
      schedule = IceCube::Schedule.new(start, conflicting_options)
      expect(schedule.duration).to eq(600)
    end

  end

  describe :occurring_at? do

    it "should not capture multiple days when called with a date" do
      schedule = IceCube::Schedule.new do |s|
        s.start_time = Time.utc(2013, 12, 31, 23, 59, 50)
        s.duration = 20
        s.add_recurrence_rule IceCube::Rule.daily(2)
      end
      expect( schedule.occurring_at?(Date.new(2014, 1, 1)) ).to eq true
      expect( schedule.occurring_at?(Date.new(2014, 1, 2)) ).to eq false
    end

  end

  describe :recurrence_times do

    it 'should start empty' do
      expect(IceCube::Schedule.new.recurrence_times).to be_empty
    end

    it 'should include added times' do
      schedule = IceCube::Schedule.new(t0 = Time.now)
      schedule.add_recurrence_time(t1 = t0 + 3600)
      expect(schedule.recurrence_times).to eq([t1])
    end

    it 'can include start time' do
      schedule = IceCube::Schedule.new(t0 = Time.now)
      schedule.add_recurrence_time(t0)
      expect(schedule.recurrence_times).to eq([t0])
    end

  end

  describe :conflicts_with? do

    it 'should raise an error if both are not terminating' do
      schedules = 2.times.map do
        schedule = IceCube::Schedule.new(Time.now)
        schedule.rrule IceCube::Rule.daily
        schedule
      end
      expect do
        schedules.first.conflicts_with?(schedules.last)
      end.to raise_error(ArgumentError)
    end

    it 'should not raise error if both are non-terminating closing time present' do
      schedule1 = IceCube::Schedule.new Time.now
      schedule1.rrule IceCube::Rule.weekly
      schedule2 = IceCube::Schedule.new Time.now
      schedule2.rrule IceCube::Rule.weekly
      expect do
        schedule1.conflicts_with?(schedule2, Time.now + IceCube::ONE_DAY)
      end.not_to raise_error
    end

    it 'should not raise an error if one is non-terminating' do
      schedule1 = IceCube::Schedule.new Time.now
      schedule1.rrule IceCube::Rule.weekly
      schedule2 = IceCube::Schedule.new Time.now
      schedule2.rrule IceCube::Rule.weekly.until(Time.now)
      expect do
        schedule1.conflicts_with?(schedule2)
      end.not_to raise_error
    end

    it 'should not raise an error if the other is non-terminating' do
      schedule1 = IceCube::Schedule.new Time.now
      schedule1.rrule IceCube::Rule.weekly.until(Time.now)
      schedule2 = IceCube::Schedule.new Time.now
      schedule2.rrule IceCube::Rule.weekly
      expect do
        schedule1.conflicts_with?(schedule2)
      end.not_to raise_error
    end

    it 'should return true if conflict is present' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time)
      schedule1.rrule IceCube::Rule.daily
      schedule2 = IceCube::Schedule.new(start_time)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_DAY)
      expect(conflict).to be_truthy
    end

    it 'should return false if conflict is not present' do
      schedule1 = IceCube::Schedule.new(TUESDAY)
      schedule1.rrule IceCube::Rule.weekly.day(:tuesday)
      schedule2 = IceCube::Schedule.new(MONDAY)
      schedule2.rrule IceCube::Rule.weekly.day(:monday)
      conflict = schedule1.conflicts_with?(schedule2, WEDNESDAY)
      expect(conflict).to be_falsey
    end

    it 'should return true if conflict is present based on duration' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_DAY + 1)
      schedule1.rrule IceCube::Rule.weekly.day(:monday)
      schedule2 = IceCube::Schedule.new(start_time)
      schedule2.rrule IceCube::Rule.weekly.day(:tuesday)
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_WEEK)
      expect(conflict).to be_truthy
    end

    it 'should return true if conflict is present based on duration - other way' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time)
      schedule1.rrule IceCube::Rule.weekly.day(:tuesday)
      schedule2 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_DAY + 1)
      schedule2.rrule IceCube::Rule.weekly.day(:monday)
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_WEEK)
      expect(conflict).to be_truthy
    end

    it 'should return false if conflict is past closing_time' do
      schedule1 = IceCube::Schedule.new(FRIDAY)
      schedule1.rrule IceCube::Rule.weekly.day(:friday)
      schedule2 = IceCube::Schedule.new(FRIDAY)
      schedule2.rrule IceCube::Rule.weekly.day(:friday)
      expect(schedule2.conflicts_with?(schedule1, MONDAY + IceCube::ONE_WEEK)).
        to be_truthy
      expect(schedule2.conflicts_with?(schedule1, MONDAY + IceCube::ONE_DAY)).
        to be_falsey
    end

    it 'should return false if conflict is not present based on duration' do
      schedule1 = IceCube::Schedule.new(MONDAY, :duration => IceCube::ONE_HOUR)
      schedule1.rrule IceCube::Rule.weekly.day(:monday)
      schedule2 = IceCube::Schedule.new(TUESDAY, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.weekly.day(:tuesday)
      conflict = schedule1.conflicts_with?(schedule2, MONDAY + IceCube::ONE_WEEK)
      expect(conflict).to be_falsey
    end

    it 'should return false if conflict is not present on same day based on duration' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.rrule IceCube::Rule.daily
      schedule2 = IceCube::Schedule.new(start_time + 3600, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_WEEK)
      expect(conflict).to be_falsey
    end

    it 'should return true if conflict is present on same day based on duration' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.rrule IceCube::Rule.daily
      schedule2 = IceCube::Schedule.new(start_time + 600, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2, start_time + IceCube::ONE_WEEK)
      expect(conflict).to be_truthy
    end

    it 'should return true if conflict is present and no recurrence' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + 600, :duration => IceCube::ONE_HOUR)
      schedule2.add_recurrence_time(start_time + 600)
      conflict = schedule1.conflicts_with?(schedule2)
      expect(conflict).to be_truthy
      conflict = schedule2.conflicts_with?(schedule1)
      expect(conflict).to be_truthy
    end

    it 'should return false if conflict is not present and no recurrence' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + IceCube::ONE_HOUR, :duration => IceCube::ONE_HOUR)
      schedule2.add_recurrence_time(start_time + IceCube::ONE_HOUR)
      conflict = schedule1.conflicts_with?(schedule2)
      expect(conflict).to be_falsey
      conflict = schedule2.conflicts_with?(schedule1)
      expect(conflict).to be_falsey
    end

    it 'should return false if conflict is not present and single recurrence' do
       start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + IceCube::ONE_HOUR, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2)
      expect(conflict).to be_falsey
      conflict = schedule2.conflicts_with?(schedule1)
      expect(conflict).to be_falsey
    end

   it 'should return true if conflict is present and single recurrence' do
      start_time = Time.now
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + 600, :duration => IceCube::ONE_HOUR)
      schedule2.rrule IceCube::Rule.daily
      conflict = schedule1.conflicts_with?(schedule2)
      expect(conflict).to be_truthy
      conflict = schedule2.conflicts_with?(schedule1)
      expect(conflict).to be_truthy
    end

    it 'should return false if conflict is not present and single recurrence and time originally specified as Time' do
      start_time = Time.local(2020, 9, 21, 11, 30, 0)
      schedule1 = IceCube::Schedule.new(start_time, :duration => IceCube::ONE_HOUR)
      schedule1.add_recurrence_time(start_time)
      schedule2 = IceCube::Schedule.new(start_time + IceCube::ONE_HOUR, :duration => IceCube::ONE_HOUR)
      schedule2.add_recurrence_time(start_time + IceCube::ONE_HOUR)
      conflict = schedule1.conflicts_with?(schedule2)
      expect(conflict).to be_falsey
      conflict = schedule2.conflicts_with?(schedule1)
      expect(conflict).to be_falsey
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
      expect(answers).to eq(schedule.first(10))
    end

    it 'should return self' do
      schedule = IceCube::Schedule.new
      expect(schedule.each_occurrence { |s| }).to eq(schedule)
    end

    it 'should stop itself when hitting the end of a schedule' do
      schedule = IceCube::Schedule.new(t0 = Time.now)
      t1 = t0 + 24 * IceCube::ONE_DAY
      schedule.add_recurrence_time t1
      answers = []
      schedule.each_occurrence { |t| answers << t }
      expect(answers).to eq([t0, t1])
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
      schedule.all_occurrences.all? { |o| expect(o.end_time).to eq(o + IceCube::ONE_HOUR) }
    end

    it 'should include its start time when empty' do
      schedule = IceCube::Schedule.new(t0 = Time.now)
      expect(schedule.all_occurrences).to eq([t0])
    end

   it 'should have one occurrence with one recurrence time at start_time' do
      schedule = IceCube::Schedule.new(t0 = Time.local(2012, 12, 12, 12, 12, 12))
      schedule.add_recurrence_time t0
      expect(schedule.all_occurrences).to eq([t0])
    end

    it 'should have two occurrences with a recurrence time after start_time' do
      schedule = IceCube::Schedule.new(t0 = Time.local(2012, 12, 12, 12, 12, 12))
      schedule.add_recurrence_time t1 = Time.local(2013,  1, 13,  1, 13,  1)
      expect(schedule.all_occurrences).to eq([t0, t1])
    end

    it 'should return an error if there is nothing to stop it' do
      schedule = IceCube::Schedule.new
      schedule.rrule IceCube::Rule.daily
      expect do
        schedule.all_occurrences
      end.to raise_error(ArgumentError)
    end

    it 'should consider count limits separately for multiple rules' do
      schedule = IceCube::Schedule.new
      schedule.rrule IceCube::Rule.minutely.count(3)
      schedule.rrule IceCube::Rule.daily.count(3)
      expect(schedule.all_occurrences.size).to eq(5)
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
      expect(occurrences).to eq([
        start_time + IceCube::ONE_DAY * 2,
        start_time + IceCube::ONE_DAY * 3
      ])
    end

    it 'should be empty if nothing is found before closing time' do
      schedule = IceCube::Schedule.new(t0 = Time.utc(2013, 1, 1)) do |s|
        next_year = Date.new(t0.year + 1, t0.month, t0.day)
        s.add_recurrence_rule nonsense.until(next_year)
      end
      trap_infinite_loop_beyond(24)
      expect(schedule.next_occurrences(1)).to be_empty
    end

    it "should not skip ahead a day when called with a date" do
      schedule = IceCube::Schedule.new(Time.utc(2014, 1, 1, 12, 34, 56)) do |s|
        s.add_recurrence_rule IceCube::Rule.hourly
      end
      next_hours = schedule.next_occurrences(2, Date.new(2014, 1, 2))
      expect( next_hours ).to eq [Time.utc(2014, 1, 2, 00, 34 , 56),
                                  Time.utc(2014, 1, 2, 01, 34 , 56)]
    end

  end

  describe :next_occurrence do

    it 'should be able to calculate the next occurrence past an exception time' do
      start_time = Time.now
      schedule = IceCube::Schedule.new start_time
      schedule.rrule IceCube::Rule.daily(1)
      schedule.extime start_time + IceCube::ONE_DAY
      occurrence = schedule.next_occurrence(start_time) # 3 occurrences in the next year
      expect(occurrence).to eq(start_time + IceCube::ONE_DAY * 2)
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

  describe :spans do

    it 'should find occurrence in past with duration beyond the start time' do
      t0 = Time.utc(2015, 10, 1, 15, 31)
      schedule = IceCube::Schedule.new(t0, :duration => 2 * IceCube::ONE_HOUR)
      schedule.add_recurrence_rule IceCube::Rule.daily
      next_occ = schedule.next_occurrence(t0 + IceCube::ONE_HOUR, :spans => true)
      expect(next_occ).to eq(t0)
    end

    it 'should include occurrence in past with duration beyond the start time' do
      t0 = Time.utc(2015, 10, 1, 15, 31)
      schedule = IceCube::Schedule.new(t0, :duration => 2 * IceCube::ONE_HOUR)
      schedule.add_recurrence_rule IceCube::Rule.daily.count(2)
      occs = schedule.next_occurrences(10, t0 + IceCube::ONE_HOUR, :spans => true)
      expect(occs).to eq([t0, t0 + IceCube::ONE_DAY])
    end

    it 'should allow duration span on remaining_occurrences' do
      t0 = Time.utc(2015, 10, 1, 00, 00)
      schedule = IceCube::Schedule.new(t0, :duration => IceCube::ONE_DAY)
      schedule.add_recurrence_rule IceCube::Rule.daily.count(3)
      occs = schedule.remaining_occurrences(t0 + IceCube::ONE_DAY + IceCube::ONE_HOUR, :spans => true)
      expect(occs).to eq([t0 + IceCube::ONE_DAY, t0 + 2 * IceCube::ONE_DAY])
    end

    it 'should include occurrences with duration spanning the requested start time' do
      t0 = Time.utc(2015, 10, 1, 15, 31)
      schedule = IceCube::Schedule.new(t0, :duration => 30 * IceCube::ONE_DAY)
      long_event = schedule.remaining_occurrences_enumerator(t0 + IceCube::ONE_DAY, :spans => true).take(1)
      expect(long_event).to eq([t0])
    end
    
    it 'should find occurrences between including previous one with duration spanning start' do
      t0 = Time.utc(2015, 10, 1, 10, 00)
      schedule = IceCube::Schedule.new(t0, :duration => IceCube::ONE_HOUR)
      schedule.add_recurrence_rule IceCube::Rule.hourly.count(10)
      occs = schedule.occurrences_between(t0 + IceCube::ONE_HOUR + 1, t0 + 3 * IceCube::ONE_HOUR + 1, :spans => true)
      expect(occs.length).to eq(3)
    end

    it 'should include long occurrences starting before and ending after' do
      t0 = Time.utc(2015, 10, 1, 00, 00)
      schedule = IceCube::Schedule.new(t0, :duration => IceCube::ONE_DAY)
      occs = schedule.occurrences_between(t0 + IceCube::ONE_HOUR, t0 + IceCube::ONE_DAY - IceCube::ONE_HOUR, :spans => true)
      expect(occs).to eq([t0])
    end

    it 'should not find occurrence with duration ending on start time' do
      t0 = Time.utc(2015, 10, 1, 12, 00)
      schedule = IceCube::Schedule.new(t0, :duration => IceCube::ONE_HOUR)
      expect(schedule.occurs_between?(t0 + IceCube::ONE_HOUR, t0 + 2 * IceCube::ONE_HOUR, :spans => true)).to be_falsey
    end
    
    it 'should quickly fetch a future time from a recurring schedule' do
      t0 = Time.utc(2000, 10, 1, 00, 00)
      t1 = Time.utc(2015, 10, 1, 12, 00)
      schedule = IceCube::Schedule.new(t0, :duration => IceCube::ONE_HOUR - 1)
      schedule.add_recurrence_rule IceCube::Rule.hourly
      occ = nil
      timing = Benchmark.realtime do
        occ = schedule.remaining_occurrences_enumerator(t1, :spans => true).take(1)
      end
      expect(timing).to be < 0.1
      expect(occ).to eq([t1])
    end
    
    it 'should not include occurrence ending on start time' do
      t0 = Time.utc(2015, 10, 1, 10, 00)
      schedule = IceCube::Schedule.new(t0, :duration => IceCube::ONE_HOUR / 2)
      schedule.add_recurrence_rule IceCube::Rule.minutely(30).count(6)
      third_occ = schedule.next_occurrence(t0 + IceCube::ONE_HOUR, :spans => true)
      expect(third_occ).to eq(t0 + IceCube::ONE_HOUR)
    end

  end

  describe :previous_occurrence do

    it 'returns the previous occurrence for a time in the schedule' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrence(t0 + 2 * IceCube::ONE_DAY)
      expect(previous).to eq(t0 + IceCube::ONE_DAY)
    end

    it 'returns nil given the start time' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrence(t0)
      expect(previous).to be_nil
    end

    it "should not skip back a day when called with a date" do
      schedule = IceCube::Schedule.new(Time.utc(2014, 1, 1, 12, 34, 56)) do |s|
        s.add_recurrence_rule IceCube::Rule.hourly
      end
      prev_hour = schedule.previous_occurrence(Date.new(2014, 1, 2))
      expect( prev_hour ).to eq Time.utc(2014, 1, 1, 23, 34 , 56)
    end

  end

  describe :previous_occurrences do

    it 'returns an array of previous occurrences from a given time' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrences(2, t0 + 3 * IceCube::ONE_DAY)
      expect(previous).to eq([t0 + IceCube::ONE_DAY, t0 + 2 * IceCube::ONE_DAY])
    end

    it 'limits the returned occurrences to a given count' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrences(999, t0 + 2 * IceCube::ONE_DAY)
      expect(previous).to eq([t0, t0 + IceCube::ONE_DAY])
    end

    it 'returns empty array given the start time' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily
      previous = schedule.previous_occurrences(2, t0)
      expect(previous).to eq([])
    end

    it "should not skip back a day when called with a date" do
      schedule = IceCube::Schedule.new(Time.utc(2014, 1, 1, 12, 34, 56)) do |s|
        s.add_recurrence_rule IceCube::Rule.hourly
      end
      prev_hours = schedule.previous_occurrences(2, Date.new(2014, 1, 2))
      expect( prev_hours ).to eq [Time.utc(2014, 1, 1, 22, 34 , 56),
                                  Time.utc(2014, 1, 1, 23, 34 , 56)]
    end

  end

  describe :last do

    it 'returns the last occurrence for a terminating schedule' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      t1 = Time.utc(2013, 5, 31, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily.until(t1 + 1)
      expect(schedule.last).to eq(t1)
    end

    it 'returns an array of occurrences given a number' do
      t0 = Time.utc(2013, 5, 18, 12, 34)
      t1 = Time.utc(2013, 5, 31, 12, 34)
      schedule = IceCube::Schedule.new(t0)
      schedule.add_recurrence_rule IceCube::Rule.daily.until(t1 + 1)
      expect(schedule.last(2)).to eq([t1 - IceCube::ONE_DAY, t1])
    end

    it 'raises an error for a non-terminating schedule' do
      schedule = IceCube::Schedule.new
      schedule.add_recurrence_rule IceCube::Rule.daily
      expect { schedule.last }.to raise_error(ArgumentError)
    end

  end

  describe :start_time= do

    it 'should modify start date in rrule_occurrence_heads when changed' do
      schedule = IceCube::Schedule.new(Time.now - 1000)
      schedule.rrule IceCube::Rule.daily
      schedule.start_time = Time.now
      expect(Time.now - schedule.first.start_time).to be < 100
    end

  end

  describe :recurrence_rules do

    it 'should not include rules for single occurrences' do
      schedule = IceCube::Schedule.new Time.now
      schedule.add_recurrence_time Time.now
      expect(schedule.rrules).to be_empty
    end

  end

  describe :remove_recurrence_rule do

    it 'should be able to one rule based on the comparator' do
      schedule = IceCube::Schedule.new Time.now
      schedule.rrule IceCube::Rule.daily
      schedule.rrule IceCube::Rule.daily(2)
      schedule.remove_recurrence_rule schedule.rrules.first
      expect(schedule.rrules.count).to eq(1)
    end

    it 'should be able to remove multiple rules based on the comparator' do
      schedule = IceCube::Schedule.new Time.now
      schedule.rrule IceCube::Rule.daily
      schedule.rrule IceCube::Rule.daily
      schedule.remove_recurrence_rule schedule.rrules.first
      expect(schedule.rrules).to be_empty
    end

    it 'should return the rule that was removed' do
      schedule = IceCube::Schedule.new Time.now
      rule = IceCube::Rule.daily
      schedule.rrule rule
      rule2 = schedule.remove_recurrence_rule rule
      expect([rule]).to eq(rule2)
    end

    it 'should return [] if nothing was removed' do
      schedule = IceCube::Schedule.new Time.now
      rule = IceCube::Rule.daily
      expect(schedule.remove_recurrence_rule(rule)).to eq([])
    end

  end

  describe :remove_recurrence_time do

    it 'should be able to remove a recurrence date from a schedule' do
      time = Time.now
      schedule = IceCube::Schedule.new(time)
      schedule.add_recurrence_time time
      schedule.remove_recurrence_time time
      expect(schedule.recurrence_times).to be_empty
    end

    it 'should return the time that was removed' do
      schedule = IceCube::Schedule.new Time.now
      time = Time.now
      schedule.rtime time
      expect(schedule.remove_rtime(time)).to eq(time)
    end

    it 'should return nil if the date was not in the schedule' do
      schedule = IceCube::Schedule.new Time.now
      expect(schedule.remove_recurrence_time(Time.now)).to be_nil
    end

  end

  describe :remove_exception_time do

    it 'should be able to remove a exception date from a schedule' do
      time = Time.now
      schedule = IceCube::Schedule.new(time)
      schedule.extime time
      schedule.remove_exception_time time
      expect(schedule.exception_times).to be_empty
    end

    it 'should return the date that was removed' do
      schedule = IceCube::Schedule.new Time.now
      time = Time.now
      schedule.extime time
      expect(schedule.remove_extime(time)).to eq(time)
    end

    it 'should return nil if the date was not in the schedule' do
      schedule = IceCube::Schedule.new Time.now
      expect(schedule.remove_exception_time(Time.now)).to be_nil
    end

  end

  describe :occurs_on? do

    subject(:schedule) { IceCube::Schedule.new(start_time) }

    shared_examples "occurring on a given day" do
      WORLD_TIME_ZONES.each do |zone|
        context "in #{zone}", :system_time_zone => zone do
          specify 'should determine if it occurs on a given Date' do
            expect(schedule.occurs_on?(Date.new(2010, 7, 1))).to be_falsey
            expect(schedule.occurs_on?(Date.new(2010, 7, 2))).to be_truthy
            expect(schedule.occurs_on?(Date.new(2010, 7, 3))).to be_falsey
          end

          specify 'should determine if it occurs on the day of a given UTC Time' do
            expect(schedule.occurs_on?(Time.utc(2010, 7, 1, 23, 59, 59))).to be_falsey
            expect(schedule.occurs_on?(Time.utc(2010, 7, 2,  0,  0,  1))).to be_truthy
            expect(schedule.occurs_on?(Time.utc(2010, 7, 2, 23, 59, 59))).to be_truthy
            expect(schedule.occurs_on?(Time.utc(2010, 7, 3,  0,  0,  1))).to be_falsey
          end

          specify 'should determine if it occurs on the day of a given local Time' do
            expect(schedule.occurs_on?(Time.local(2010, 7, 1, 23, 59, 59))).to be_falsey
            expect(schedule.occurs_on?(Time.local(2010, 7, 2,  0,  0,  1))).to be_truthy
            expect(schedule.occurs_on?(Time.local(2010, 7, 2, 23, 59, 59))).to be_truthy
            expect(schedule.occurs_on?(Time.local(2010, 7, 3,  0,  0,  1))).to be_falsey
          end

          specify 'should determine if it occurs on the day of a given non-local Time' do
            expect(schedule.occurs_on?(Time.new(2010, 7, 1, 23, 59, 59, "+11:15"))).to be_falsey
            expect(schedule.occurs_on?(Time.new(2010, 7, 2,  0,  0,  1, "+11:15"))).to be_truthy
            expect(schedule.occurs_on?(Time.new(2010, 7, 2, 23, 59, 59, "+11:15"))).to be_truthy
            expect(schedule.occurs_on?(Time.new(2010, 7, 3,  0,  0,  1, "+11:15"))).to be_falsey
          end

          specify 'should determine if it occurs on the day of a given ActiveSupport::Time', :requires_active_support => true do
            Time.zone = "Pacific/Honolulu"
            expect(schedule.occurs_on?(Time.zone.parse('2010-07-01 23:59:59'))).to be_falsey
            expect(schedule.occurs_on?(Time.zone.parse('2010-07-02 00:00:01'))).to be_truthy
            expect(schedule.occurs_on?(Time.zone.parse('2010-07-02 23:59:59'))).to be_truthy
            expect(schedule.occurs_on?(Time.zone.parse('2010-07-03 00:00:01'))).to be_falsey
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

      context 'starting from an ActiveSupport::Time', :requires_active_support => true do
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

    context 'across DST' do
      let(:start_time) { Time.local(2010, 3, 2, 0, 0, 0) }
      before { schedule.add_recurrence_rule(IceCube::Rule.monthly) }
      it 'determines local midnight with time change' do
        expect(schedule.occurs_on?(Date.new(2010, 7, 2))).to be_truthy
      end
    end

    it 'should be true for multiple rtimes' do
      schedule = IceCube::Schedule.new(Time.local(2010, 7, 10, 16))
      schedule.add_recurrence_time(Time.local(2010, 7, 11, 16))
      schedule.add_recurrence_time(Time.local(2010, 7, 12, 16))
      schedule.add_recurrence_time(Time.local(2010, 7, 13, 16))

      expect(schedule.occurs_on?(Date.new(2010, 7, 11))).to be_truthy
      expect(schedule.occurs_on?(Date.new(2010, 7, 12))).to be_truthy
      expect(schedule.occurs_on?(Date.new(2010, 7, 13))).to be_truthy
    end

  end

  def compare_time_zone_info(start_time)
    schedule = IceCube::Schedule.new(start_time)
    schedule.rrule IceCube::Rule.yearly(1)
    occurrence = schedule.next_occurrence

    expect(occurrence.dst?).to eq(start_time.dst?) if start_time.respond_to? :dst?
    expect(occurrence.utc?).to eq(start_time.utc?) if start_time.respond_to? :utc?
    expect(occurrence.zone).to eq(start_time.zone)
    occurrence.utc_offset == start_time.utc_offset
  end

  def trap_infinite_loop_beyond(iterations)
    expect_any_instance_of(IceCube::ValidatedRule).to receive(:finds_acceptable_time?).
                          at_most(iterations).times.and_call_original
  end
end
