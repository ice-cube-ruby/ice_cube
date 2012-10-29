require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::MonthlyRule, 'occurs_on?' do

  it 'should not produce results for @interval = 0' do
    start_date = DAY
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.monthly(0)
    #check assumption
    schedule.occurrences(start_date + 50 * IceCube::ONE_DAY).size.should == 0
  end
  
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

end
