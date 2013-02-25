require File.dirname(__FILE__) + '/../spec_helper'
require 'active_support/time'


module IceCube
  describe Schedule, 'using ActiveSupport' do

    before(:all) { Time.zone = 'Eastern Time (US & Canada)' }

    around(:each) do |example|
      Time.zone = 'America/Anchorage'
      orig_tz, ENV['TZ'] = ENV['TZ'], 'Pacific/Auckland'
      example.run
      ENV['TZ'] = orig_tz
    end

    it 'works with a single recurrence time starting from a TimeWithZone' do
      schedule = Schedule.new(t0 = Time.zone.parse("2010-02-05 05:00:00"))
      schedule.add_recurrence_time t0
      schedule.all_occurrences.should == [t0]
    end

    it 'works with a monthly recurrence rule starting from a TimeWithZone' do
      schedule = Schedule.new(t0 = Time.zone.parse("2010-02-05 05:00:00"))
      schedule.add_recurrence_rule Rule.monthly
      schedule.first(10).should == [
        Time.zone.parse("2010-02-05 05:00"), Time.zone.parse("2010-03-05 05:00"),
        Time.zone.parse("2010-04-05 05:00"), Time.zone.parse("2010-05-05 05:00"),
        Time.zone.parse("2010-06-05 05:00"), Time.zone.parse("2010-07-05 05:00"),
        Time.zone.parse("2010-08-05 05:00"), Time.zone.parse("2010-09-05 05:00"),
        Time.zone.parse("2010-10-05 05:00"), Time.zone.parse("2010-11-05 05:00")
      ]
    end

    it 'works with a monthly schedule converting to UTC across DST' do
      Time.zone = 'Eastern Time (US & Canada)'
      schedule = Schedule.new(t0 = Time.zone.parse("2009-10-28 19:30:00"))
      schedule.add_recurrence_rule Rule.monthly
      schedule.first(7).map { |d| d.getutc }.should == [
        Time.utc(2009, 10, 28, 23, 30, 0), Time.utc(2009, 11, 29,  0, 30, 0),
        Time.utc(2009, 12, 29,  0, 30, 0), Time.utc(2010,  1, 29,  0, 30, 0),
        Time.utc(2010,  3,  1,  0, 30, 0), Time.utc(2010,  3, 28, 23, 30, 0),
        Time.utc(2010,  4, 28, 23, 30, 0)
      ]
    end

    it 'can round trip TimeWithZone to YAML' do
      schedule = Schedule.new(t0 = Time.zone.parse("2010-02-05 05:00:00"))
      schedule.add_recurrence_time t0
      schedule2 = Schedule.from_yaml(schedule.to_yaml)
      schedule.all_occurrences.should == schedule2.all_occurrences
    end

    it 'uses local zone from start time to determine occurs_on? from the beginning of day' do
      schedule = Schedule.new(t0 = Time.local(2009, 2, 7, 23, 59, 59))
      schedule.add_recurrence_rule Rule.daily
      schedule.occurs_on?(Date.new(2009, 2, 7)).should be_true
    end

    it 'uses local zone from start time to determine occurs_on? to the end of day' do
      schedule = Schedule.new(t0 = Time.local(2009, 2, 7, 0, 0, 0))
      schedule.add_recurrence_rule Rule.daily
      schedule.occurs_on?(Date.new(2009, 2, 7)).should be_true
    end

    it 'should use the correct zone for next_occurrences before start_time' do
      future_time = Time.zone.now.beginning_of_day + 1.day
      schedule = Schedule.new(future_time)
      schedule.add_recurrence_rule Rule.daily
      schedule.next_occurrence.time_zone.should == schedule.start_time.time_zone
    end

    it 'should use the correct zone for next_occurrences after start_time' do
      past_time = Time.zone.now.beginning_of_day
      schedule = Schedule.new(past_time)
      schedule.add_recurrence_rule Rule.daily
      schedule.next_occurrence.time_zone.should == schedule.start_time.time_zone
    end

  end
end

describe IceCube::Occurrence do

  it 'can be subtracted from a time' do
    start_time = Time.now
    occurrence = Occurrence.new(start_time)

    difference = (start_time + 60) - occurrence
    difference.should == 60
  end

end
