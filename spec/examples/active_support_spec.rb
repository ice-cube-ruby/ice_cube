require 'active_support/time'
require File.dirname(__FILE__) + '/../spec_helper'

Time.zone = 'Eastern Time (US & Canada)'

describe IceCube::Schedule, 'occurs_on?' do

  it 'works with a single recurrence date in a TimeWithZone timezone' do
    Time.zone = "Pacific Time (US & Canada)"
    start_date = Time.zone.parse("2010-02-05 05:00:00")
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_date start_date
    dates = schedule.all_occurrences
    dates.should == [start_date]
  end
  
  it 'works with a monthly recurrence rule in a TimeWithZone timezone' do
    Time.zone = "Pacific Time (US & Canada)"
    start_date = Time.zone.parse("2010-02-05 05:00:00")
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly
    dates = schedule.first(10)
    dates.should == [Time.zone.parse("2010-02-05 05:00:00"), Time.zone.parse("2010-03-05 05:00:00"), Time.zone.parse("2010-04-05 05:00:00"), 
                     Time.zone.parse("2010-05-05 05:00:00"), Time.zone.parse("2010-06-05 05:00:00"), Time.zone.parse("2010-07-05 05:00:00"),
                     Time.zone.parse("2010-08-05 05:00:00"), Time.zone.parse("2010-09-05 05:00:00"), Time.zone.parse("2010-10-05 05:00:00"), 
                     Time.zone.parse("2010-11-05 05:00:00")]
  end
  
  it 'works with a monthly schedule converting to UTC' do
    Time.zone = "Eastern Time (US & Canada)"
    start_date = Time.zone.parse("2009-10-28 19:30:00") #e9337
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly
    dates = schedule.first(7)
    # get the utc dates
    dates = dates.map { |d| d.getutc }
    # check expectations
    dates.should == [Time.utc(2009, 10, 28, 23, 30, 0), Time.utc(2009, 11, 29, 0, 30, 0), Time.utc(2009, 12, 29, 0, 30, 0), 
                     Time.utc(2010, 1, 29, 0, 30, 0),   Time.utc(2010, 3, 1, 0, 30, 0),   Time.utc(2010, 3, 28, 23, 30, 0),
                     Time.utc(2010, 4, 28, 23, 30, 0)]
  end
  
  it 'can make a round trip to yaml with TimeWithZone' do
    Time.zone = "Pacific Time (US & Canada)"
    start_date = Time.zone.parse("2010-02-05 05:00:00")
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_date start_date
    # create a schedule out of round trip
    schedule2 = IceCube::Schedule.from_yaml(schedule.to_yaml)
    #compare results
    schedule.all_occurrences.should == schedule2.all_occurrences
  end

  it 'should work with occurs_on? and a boundary of a day in a different time_zone' do
    schedule = IceCube::Schedule.new(Time.local(2009, 2, 7, 10, 30, 0))
    schedule.add_recurrence_rule IceCube::Rule.daily
    schedule.occurs_on?(Date.new(2009, 2, 7)).should be(true)
  end

  it 'should work in the occurs_on? boundary condition to the beginning of the day' do
    schedule = IceCube::Schedule.new(Time.local(2009, 2, 7, 23, 59, 59))
    schedule.add_recurrence_rule IceCube::Rule.daily
    schedule.occurs_on?(Date.new(2009, 2, 7)).should be(true)
  end

  it 'should work in the occurs_on? boundary condition to the end of the day' do
    schedule = IceCube::Schedule.new(Time.local(2009, 2, 7, 0, 0, 0))
    schedule.add_recurrence_rule IceCube::Rule.daily
    schedule.occurs_on?(Date.new(2009, 2, 7)).should be(true)
  end
  
end

