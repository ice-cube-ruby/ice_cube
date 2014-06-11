require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::YearlyRule, 'interval validation' do
  it 'converts a string integer to an actual int when using the interval method' do
    rule = Rule.yearly.interval("2")
    expect(rule.validations_for(:interval).first.interval).to eq(2)
  end

  it 'converts a string integer to an actual int when using the initializer' do
    rule = Rule.yearly("3")
    expect(rule.validations_for(:interval).first.interval).to eq(3)
  end

  it 'raises an argument error when a bad value is passed' do
    expect {
      rule = Rule.yearly("invalid")
    }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass an integer.")
  end

  it 'raises an argument error when a bad value is passed using the interval method' do
    expect {
      rule = Rule.yearly.interval("invalid")
    }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass an integer.")
  end

end

describe IceCube::YearlyRule, 'occurs_on?' do

  it 'should update previous interval' do
    schedule = double(start_time: t0 = Time.utc(2013, 5, 1))
    rule = Rule.yearly(3)
    rule.interval(1)
    expect(rule.next_time(t0 + 1, schedule, nil)).to eq(t0 + 365.days)
  end

  it 'should be able to specify complex yearly rules' do
    start_date = Time.local(2010, 7, 12, 5, 0, 0)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:april).day_of_week(:monday => [1, -1])
    #check assumption - over 1 year should be 2
    expect(schedule.occurrences(start_date + IceCube::TimeUtil.days_in_year(start_date) * IceCube::ONE_DAY).size).to eq(2)
  end

  it 'should produce the correct number of days for @interval = 1' do
    start_date = Time.now
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly
    #check assumption
    expect(schedule.occurrences(start_date + 370 * IceCube::ONE_DAY).size).to eq(2)
  end

  it 'should produce the correct number of days for @interval = 2' do
    start_date = Time.now
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly(2)
    #check assumption
    expect(schedule.occurrences(start_date + 370 * IceCube::ONE_DAY)).to eq([start_date])
  end

  it 'should produce the correct number of days for @interval = 1 when you specify months' do
    start_date = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:january, :april, :november)
    #check assumption
    expect(schedule.occurrences(Time.utc(2010, 12, 31)).size).to eq(3)
  end

  it 'should produce the correct number of days for @interval = 1 when you specify days' do
    start_date = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_date)
    schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(155, 200)
    #check assumption
    expect(schedule.occurrences(Time.utc(2010, 12, 31)).size).to eq(2)
  end

  it 'should produce the correct number of days for @interval = 1 when you specify negative days' do
    schedule = IceCube::Schedule.new(Time.utc(2010, 1, 1))
    schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(100, -1)
    #check assumption
    expect(schedule.occurrences(Time.utc(2010, 12, 31)).size).to eq(2)
  end

end
