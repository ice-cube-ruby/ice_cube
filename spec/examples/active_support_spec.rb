require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'occurs_on?' do

  require 'rubygems'
  gem 'activesupport'
  require 'active_support'

  it 'works with a single recurrence date in a TimeWithZone timezone' do
    Time.zone = "Pacific Time (US & Canada)"
    start_date = Time.zone.parse("2010-02-05 05:00:00")
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_date start_date
    dates = schedule.all_occurrences
    dates.should == [start_date]
  end
  
  it 'works with a monthly recurrence rule in a TimeWithZone timezone' do
    Time.zone = "Pacific Time (US & Canada)"
    start_date = Time.zone.parse("2010-02-05 05:00:00")
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly
    dates = schedule.first(10)
    dates.should == [Time.zone.parse("2010-02-05 05:00:00"), Time.zone.parse("2010-03-05 05:00:00"), Time.zone.parse("2010-04-05 05:00:00"), 
                     Time.zone.parse("2010-05-05 05:00:00"), Time.zone.parse("2010-06-05 05:00:00"), Time.zone.parse("2010-07-05 05:00:00"),
                     Time.zone.parse("2010-08-05 05:00:00"), Time.zone.parse("2010-09-05 05:00:00"), Time.zone.parse("2010-10-05 05:00:00"), 
                     Time.zone.parse("2010-11-05 05:00:00")]
  end
  
  it 'works with a monthly schedule converting to UTC' do
    Time.zone = "Eastern Time (US & Canada)"
    start_date = Time.zone.parse("2009-10-28 19:30:00") #e9337
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly
    dates = schedule.first(7)
    # get the utc dates
    dates = dates.map { |d| d.getutc }
    # check expectations
    dates.should == [Time.utc(2009, 10, 28, 23, 30, 0), Time.utc(2009, 11, 29, 0, 30, 0), Time.utc(2009, 12, 29, 0, 30, 0), 
                     Time.utc(2010, 1, 29, 0, 30, 0),   Time.utc(2010, 3, 1, 0, 30, 0),   Time.utc(2010, 3, 28, 23, 30, 0),
                     Time.utc(2010, 4, 28, 23, 30, 0)]
  end
   
end
