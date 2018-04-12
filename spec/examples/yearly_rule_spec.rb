require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::YearlyRule, 'interval validation' do
  it 'converts a string integer to an actual int when using the interval method' do
    rule = IceCube::Rule.yearly.interval("2")
    expect(rule.validations_for(:interval).first.interval).to eq(2)
  end

  it 'converts a string integer to an actual int when using the initializer' do
    rule = IceCube::Rule.yearly("3")
    expect(rule.validations_for(:interval).first.interval).to eq(3)
  end

  it 'raises an argument error when a bad value is passed' do
    expect {
      Rule.yearly("invalid")
    }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
  end

  it 'raises an argument error when a bad value is passed using the interval method' do
    expect {
      Rule.yearly.interval("invalid")
    }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
  end

end

describe IceCube::YearlyRule do

  it 'should update previous interval' do
    t0 = Time.utc(2013, 5, 1)
    rule = Rule.yearly(3)
    rule.interval(1)
    expect(rule.next_time(t0 + 1, t0, nil)).to eq(t0 + (IceCube::ONE_DAY * 365))
  end

  it 'should be able to specify complex yearly rules' do
    start_time = Time.local(2010, 7, 12, 5, 0, 0)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:april).day_of_week(:monday => [1, -1])

    one_year = 365 * IceCube::ONE_DAY
    expect(schedule.occurrences(start_time + one_year)).to eq [
      start_time,
      Time.local(2011, 4,  4, 5, 0),
      Time.local(2011, 4, 25, 5, 0),
    ]
  end

  it 'should produce the correct number of days for @interval = 1' do
    start_time = Time.now
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.yearly
    #check assumption
    expect(schedule.occurrences(start_time + 370 * IceCube::ONE_DAY).size).to eq(2)
  end

  it 'should produce the correct number of days for @interval = 2' do
    start_time = Time.now
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.yearly(2)
    #check assumption
    expect(schedule.occurrences(start_time + 370 * IceCube::ONE_DAY)).to eq([start_time])
  end

  it 'should produce the correct days for @interval = 1 when you specify months' do
    start_time = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:january, :april, :november)

    months_of_year = [Time.utc(2010,1,1), Time.utc(2010,4,1), Time.utc(2010,11,1)]
    expect(schedule.occurrences(Time.utc(2010, 12, 31))).to eq months_of_year
  end

  it 'should produce the correct days for @interval = 1 when you specify days' do
    start_time = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(155, 200)

    expect(schedule.occurrences(Time.utc(2010, 12, 31))).to eq [
      start_time,
      Time.utc(2010, 6, 4),
      Time.utc(2010, 7, 19),
    ]
  end

  it 'should produce the correct days for @interval = 1 when you specify negative days' do
    start_time = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(100, -1)

    expect(schedule.occurrences(Time.utc(2010, 12, 31))).to eq [
      start_time,
      Time.utc(2010, 4, 10),
      Time.utc(2010, 12, 31),
    ]
  end

  it 'should handle negative offset day of year for leap years' do
    start_time = Time.utc(2010, 1, 1)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(-1)

    expect(schedule.occurrences(Time.utc(2014, 12, 31))).to eq [
      start_time,
      Time.utc(2010, 12, 31),
      Time.utc(2011, 12, 31),
      Time.utc(2012, 12, 31),
      Time.utc(2013, 12, 31),
      Time.utc(2014, 12, 31),
    ]
  end

end
