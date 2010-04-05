require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'ice_cube')
include IceCube

require 'date' # used to build some dates

#some custom dates
DAY = Time.utc(2010, 3, 1)

def test_expectations(schedule, dates_array)
  expectation = []
  dates_array.each do |y, months|
    months.each do |m, days|
      days.each do |d|
        expectation << Time.utc(y, m, d)
      end
    end
  end
  #test equality
  expectation.sort!
  schedule.occurrences(expectation.last).should == expectation
  expectation.each do |date|
    schedule.should be_occurs_on(date)
  end
end