require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::MonthlyRule, 'occurs_on?' do

  it 'should produce the correct number of days for @interval = 1' do
    start_date = DAY
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly
    #check assumption
    schedule.occurrences(start_date + 50 * IceCube::ONE_DAY).size.should == 2
  end

  it 'should produce the correct number of days for @interval = 2' do
    start_date = DAY
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly(2)
    schedule.occurrences(start_date + 50 * IceCube::ONE_DAY).size.should == 1
  end

  it 'should produce the correct number of days for @interval = 1 with only the 1st and 15th' do
    start_date = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(1, 15)
    #check assumption (1) (15) (1) (15)
    schedule.occurrences(start_date + 50 * IceCube::ONE_DAY).size.should == 4
  end

  it 'should produce the correct number of days for @interval = 1 with only the 1st and last' do
    start_date = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(1, -1)
    #check assumption (1) (31) (1)
    schedule.occurrences(start_date + 50 * IceCube::ONE_DAY).size.should == 3
  end

  it 'should produce the correct number of days for @interval = 1 with only the first mondays' do
    start_date = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_week(:monday => [1])
    #check assumption (month 1 monday) (month 2 monday)
    schedule.occurrences(start_date + 50 * IceCube::ONE_DAY).size.should == 2
  end

  it 'should produce the correct number of days for @interval = 1 with only the last mondays' do
    start_date = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_week(:monday => [-1])
    #check assumption (month 1 monday)
    schedule.occurrences(start_date + 40 * IceCube::ONE_DAY).size.should == 1
  end

  it 'should produce the correct number of days for @interval = 1 with only the first and last mondays' do
    start_date = Time.utc(2010, 1, 1)
    end_date = Time.utc(2010, 12, 31)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_week(:monday => [1, -2])
    #check assumption (12 months - 2 dates each)
    schedule.occurrences(end_date).size.should == 24
  end

  it 'should produce dates on a monthly interval for the last day of the month' do
    start_date = Time.utc(2010, 3, 31, 0, 0, 0)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly
    schedule.first(10).should == [Time.utc(2010, 3, 31, 0, 0, 0), Time.utc(2010, 4, 30, 0, 0, 0), Time.utc(2010, 5, 31, 0, 0, 0),
                                  Time.utc(2010, 6, 30, 0, 0, 0), Time.utc(2010, 7, 31, 0, 0, 0), Time.utc(2010, 8, 31, 0, 0, 0),
                                  Time.utc(2010, 9, 30, 0, 0, 0), Time.utc(2010, 10, 31, 0, 0, 0), Time.utc(2010, 11, 30, 0, 0, 0),
                                  Time.utc(2010, 12, 31, 0, 0, 0)]
  end

  it 'should produce dates on a monthly interval for latter days in the month near February' do
    start_date = Time.utc(2010, 1, 29, 0, 0, 0)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly
    schedule.first(3).should == [Time.utc(2010, 1, 29, 0, 0, 0), Time.utc(2010, 2, 28, 0, 0, 0), Time.utc(2010, 3, 29, 0, 0, 0)]
  end
end
