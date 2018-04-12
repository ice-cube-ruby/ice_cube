require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::Schedule do

  it 'should ~ daily for 10 occurrences' do
    schedule = IceCube::Schedule.new(Time.utc(2010, 9, 2))
    schedule.add_recurrence_rule IceCube::Rule.daily.count(10)
    test_expectations(schedule, {2010 => {9 => [2, 3, 4, 5, 6, 7, 8, 9, 10, 11]}})
  end

  it 'should ~ daily until a certain date' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 9, 2))
    schedule.add_recurrence_rule IceCube::Rule.daily.until(Time.utc(1997, 12, 24))
    dates = schedule.all_occurrences
    expectation = (Date.civil(1997, 9, 2)..Date.civil(1997, 12, 24)).to_a
    expectation = expectation.map { |d| Time.utc(d.year, d.month, d.day) }
    expect(dates).to eq(expectation)
  end

  it 'should ~ every other day' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 9, 2))
    schedule.add_recurrence_rule IceCube::Rule.daily(2).until(Time.utc(1997, 12, 24))
    dates = schedule.occurrences(Time.utc(1997, 12, 31))
    offset = 0
    (Date.new(1997, 9, 2)..Date.new(1997, 12, 24)).each do |date|
      expect(dates).to include(Time.utc(date.year, date.month, date.day)) if offset % 2 == 0
      expect(dates).not_to include(Time.utc(date.year, date.month, date.day)) if offset % 2 != 0
      offset += 1
    end
  end

  it 'should ~ interval 10, count 5' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 9, 2))
    schedule.add_recurrence_rule IceCube::Rule.daily(10).count(5)
    dates = schedule.occurrences(Time.utc(1998, 1, 1))
    expect(dates).to eq([Time.utc(1997, 9, 2), Time.utc(1997, 9, 12), Time.utc(1997, 9, 22), Time.utc(1997, 10, 2), Time.utc(1997, 10, 12)])
  end

  it 'should ~ everyday in january, for 3 years (a)' do
    schedule = IceCube::Schedule.new(Time.utc(1998, 1, 1))
    schedule.add_recurrence_rule IceCube::Rule.yearly.until(Time.utc(2000, 1, 31)).month_of_year(:january).day(:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday)
    dates = schedule.occurrences(Time.utc(2000, 1, 31))
    dates.each do |date|
      expect(date.month).to eq(1)
      expect([1998, 1999, 2000]).to include(date.year)
    end
  end

  it 'should ~ everyday in january, for 3 years (b)' do
    schedule = IceCube::Schedule.new(Time.utc(1998, 1, 1))
    schedule.add_recurrence_rule IceCube::Rule.daily.month_of_year(:january).until(Time.utc(2000, 1, 31))
    dates = schedule.occurrences(Time.utc(2000, 1, 31))
    dates.each do |date|
      expect(date.month).to eq(1)
      expect([1998, 1999, 2000]).to include(date.year)
    end
  end

  it 'should ~ weekly for 10 occurrences' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 9, 2))
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(10)
    dates = schedule.occurrences(Time.utc(2000, 1, 1))
    expect(dates).to eq([Time.utc(1997, 9, 2), Time.utc(1997, 9, 9), Time.utc(1997, 9, 16), Time.utc(1997, 9, 23), Time.utc(1997, 9, 30), Time.utc(1997, 10, 7), Time.utc(1997, 10, 14), Time.utc(1997, 10, 21), Time.utc(1997, 10, 28), Time.utc(1997, 11, 4)])
  end

  it 'should ~ weekly until december 24, 1997' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 9, 2))
    schedule.add_recurrence_rule IceCube::Rule.weekly.until(Time.utc(1997, 12, 24))

    test_expectations(schedule, {1997 => {9 => [2, 9, 16, 23, 30], 10 => [7, 14, 21, 28], 11 => [4, 11, 18, 25], 12 => [2, 9, 16, 23]}})
  end

  it 'should ~ every other week' do
    start_time = Time.utc(1997, 9, 2)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.weekly(2)
    dates = schedule.occurrences(Time.utc(1997, 12, 31))
    #check assumption
    previous_date = dates.shift
    dates.each do |date|
      expect(date.yday).to eq(previous_date.yday + 14)
      previous_date = date
    end
  end

  it 'should ~ weekly on tuesday and thursday for 5 weeks (a)' do
    start_time = Time.utc(1997, 9, 2)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.weekly.until(Time.utc(1997, 10, 6)).day(:tuesday, :thursday)
    dates = schedule.occurrences(Time.utc(1997, 12, 1))
    expectation = []
    expectation << [2, 4, 9, 11, 16, 18, 23, 25, 30].map { |d| Time.utc(1997, 9, d) }
    expectation << [2].map { |d| Time.utc(1997, 10, d) }
    expect(dates).to eq(expectation.flatten)
  end

  it 'should ~ weekly on tuesday and thursday for 5 weeks (b)' do
    start_time = Time.utc(1997, 9, 2)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day(:tuesday, :thursday).count(10)
    dates = schedule.occurrences(Time.utc(1997, 12, 1))
    expectation = []
    expectation << [2, 4, 9, 11, 16, 18, 23, 25, 30].map { |d| Time.utc(1997, 9, d) }
    expectation << [2].map { |d| Time.utc(1997, 10, d) }
    expect(dates).to eq(expectation.flatten)
  end

  it 'should ~ every other week on monday, wednesday and friday until december 24, 1997 but starting on tuesday september 2, 1997' do
    start_time = Time.utc(1997, 9, 2)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.weekly(2).until(Time.utc(1997, 12, 24)).day(:monday, :wednesday, :friday)
    dates = schedule.occurrences(Time.utc(1997, 12, 24))
    expectation = [start_time]
    expectation << [3, 5, 15, 17, 19, 29].map { |d| Time.utc(1997, 9, d) }
    expectation << [1, 3, 13, 15, 17, 27, 29, 31].map { |d| Time.utc(1997, 10, d) }
    expectation << [10, 12, 14, 24, 26, 28].map { |d| Time.utc(1997, 11, d) }
    expectation << [8, 10, 12, 22, 24].map { |d| Time.utc(1997, 12, d) }
    expect(dates).to eq(expectation.flatten)
  end

  it 'should ~ every other week on tuesday and thursday for 8 occurrences' do
    start_time = Time.utc(1997, 9, 2)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.weekly(2).day(:tuesday, :thursday).count(8)
    dates = schedule.occurrences(Time.utc(1997, 11, 1))
    expectation = []
    expectation << [2, 4, 16, 18, 30].map { |d| Time.utc(1997, 9, d) }
    expectation << [2, 14, 16].map { |d| Time.utc(1997, 10, d) }
    expect(dates).to eq(expectation.flatten)
  end

  it 'should ~ monthly on the 1st friday for ten occurrences' do
    start_time = Time.utc(1997, 9, 5)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_week(:friday => [1]).count(10)
    dates = schedule.occurrences(Time.utc(1998, 7, 1))
    expectation = [Time.utc(1997, 9, 5), Time.utc(1997, 10, 3), Time.utc(1997, 11, 7), Time.utc(1997, 12, 5), Time.utc(1998, 1, 2), Time.utc(1998, 2, 6), Time.utc(1998, 3, 6), Time.utc(1998, 4, 3), Time.utc(1998, 5, 1), Time.utc(1998, 6, 5)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ monthly on the first friday until december 24, 1997' do
    start_time = Time.utc(1997, 9, 5)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.monthly.until(Time.utc(1997, 12, 24)).day_of_week(:friday => [1])
    dates = schedule.occurrences(Time.utc(1998, 12, 24))
    expectation = [Time.utc(1997, 9, 5), Time.utc(1997, 10, 3), Time.utc(1997, 11, 7), Time.utc(1997, 12, 5)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ every other month on the 1st and last sunday of the month for 10 occurrences' do
    start_time = Time.utc(1997, 9, 7)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.monthly(2).day_of_week(:sunday => [1, -1]).count(10)
    dates = schedule.occurrences(Time.utc(1998, 12, 1))
    expectation = [Time.utc(1997, 9, 7), Time.utc(1997, 9, 28), Time.utc(1997, 11, 2), Time.utc(1997, 11, 30), Time.utc(1998, 1, 4), Time.utc(1998, 1, 25), Time.utc(1998, 3, 1), Time.utc(1998, 3, 29), Time.utc(1998, 5, 3), Time.utc(1998, 5, 31)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ monthly on the second to last monday of the month for 6 months' do
    start_time = Time.utc(1997, 9, 22)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_week(:monday => [-2]).count(6)
    dates = schedule.occurrences(Time.utc(1998, 3, 1))
    expectation = [Time.utc(1997, 9, 22), Time.utc(1997, 10, 20), Time.utc(1997, 11, 17), Time.utc(1997, 12, 22), Time.utc(1998, 1, 19), Time.utc(1998, 2, 16)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ monthly on the third to last day of the month, 6 times' do
    start_time = Time.utc(1997, 9, 28)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(-3).count(6)
    dates = schedule.occurrences(Time.utc(1998, 2, 26))
    expectation = [Time.utc(1997, 9, 28), Time.utc(1997, 10, 29), Time.utc(1997, 11, 28), Time.utc(1997, 12, 29), Time.utc(1998, 1, 29), Time.utc(1998, 2, 26)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ monthly on the 2nd and 15th of the month for 10 occurrences' do
    start_time = Time.utc(1997, 9, 2)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(2, 15).count(10)
    dates = schedule.occurrences(Time.utc(1998, 1, 16))
    expectation = [Time.utc(1997, 9, 2), Time.utc(1997, 9, 15), Time.utc(1997, 10, 2), Time.utc(1997, 10, 15), Time.utc(1997, 11, 2), Time.utc(1997, 11, 15), Time.utc(1997, 12, 2), Time.utc(1997, 12, 15), Time.utc(1998, 1, 2), Time.utc(1998, 1, 15)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ monthly on the 1st and last days of the month for 10 occurrences' do
    start_time = Time.utc(1997, 9, 30)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(1, -1).count(10)
    dates = schedule.occurrences(Time.utc(1998, 2, 2))
    expectation = [Time.utc(1997, 9, 30), Time.utc(1997, 10, 1), Time.utc(1997, 10, 31), Time.utc(1997, 11, 1), Time.utc(1997, 11, 30), Time.utc(1997, 12, 1), Time.utc(1997, 12, 31), Time.utc(1998, 1, 1), Time.utc(1998, 1, 31), Time.utc(1998, 2, 1)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ every 18 months on the 10th through the 15th of the month for 10 occurrences' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 9, 10))
    schedule.add_recurrence_rule IceCube::Rule.monthly(18).day_of_month(10, 11, 12, 13, 14, 15).count(10)
    dates = schedule.occurrences(Time.utc(1999, 12, 1))
    expectation = []
    expectation << [10, 11, 12, 13, 14, 15].map { |d| Time.utc(1997, 9, d) }
    expectation << [10, 11, 12, 13].map { |d| Time.utc(1999, 3, d) }
    expect(dates).to eq(expectation.flatten)
  end

  it 'should ~ every tuesday, every other month' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 9, 2))
    schedule.add_recurrence_rule IceCube::Rule.monthly(2).day(:tuesday)
    dates = schedule.occurrences(Time.utc(1998, 4, 1))
    expectation = []
    expectation << [2, 9, 16, 23, 30].map { |d| Time.utc(1997, 9, d) }
    expectation << [4, 11, 18, 25].map { |d| Time.utc(1997, 11, d) }
    expectation << [6, 13, 20, 27].map { |d| Time.utc(1998, 1, d) }
    expectation << [3, 10, 17, 24, 31].map { |d| Time.utc(1998, 3, d) }
    expect(dates).to eq(expectation.flatten)
  end

  it 'should ~ yearly in june and july for 10 occurrences' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 6, 10))
    schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:june, :july).count(10)
    dates = schedule.occurrences(Time.utc(2001, 8, 1))
    expectation = []
    (1997..2001).each do |year|
      expectation << Time.utc(year, 6, 10)
      expectation << Time.utc(year, 7, 10)
    end
    expect(dates).to eq(expectation.flatten)
  end

  it 'should ~ every other year on january, feburary, and march for 10 occurrences' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 3, 10))
    schedule.add_recurrence_rule IceCube::Rule.yearly(2).month_of_year(:january, :february, :march).count(10)
    dates = schedule.occurrences(Time.utc(2003, 4, 1))
    expectation = [Time.utc(1997, 3, 10), Time.utc(1999, 1, 10), Time.utc(1999, 2, 10), Time.utc(1999, 3, 10), Time.utc(2001, 1, 10), Time.utc(2001, 2, 10), Time.utc(2001, 3, 10), Time.utc(2003, 1, 10), Time.utc(2003, 2, 10), Time.utc(2003, 3, 10)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ every third year on the 1st, 100th and 200th day for 10 occurrences' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 1, 1))
    schedule.add_recurrence_rule IceCube::Rule.yearly(3).day_of_year(1, 100, 200).count(10)
    dates = schedule.occurrences(Time.utc(2006, 1, 2))
    expectation = [Time.utc(1997, 1, 1), Time.utc(1997, 4, 10), Time.utc(1997, 7, 19), Time.utc(2000, 1, 1), Time.utc(2000, 4, 9), Time.utc(2000, 7, 18), Time.utc(2003, 1, 1), Time.utc(2003, 4, 10), Time.utc(2003, 7, 19), Time.utc(2006, 1, 1)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ every thursday in march, forever' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 3, 13))
    schedule.add_recurrence_rule IceCube::Rule.yearly.month_of_year(:march).day(:thursday)
    dates = schedule.occurrences(Time.utc(1999, 3, 25))
    expectation = []
    expectation << [13, 20, 27].map { |d| Time.utc(1997, 3, d) }
    expectation << [5, 12, 19, 26].map { |d| Time.utc(1998, 3, d) }
    expectation << [4, 11, 18, 25].map { |d| Time.utc(1999, 3, d) }
    expect(dates).to eq(expectation.flatten)
  end

  it 'should ~ every thursday, but only during june, july, and august' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 6, 5))
    schedule.add_recurrence_rule IceCube::Rule.yearly.day(:thursday).month_of_year(:june, :july, :august)
    dates = schedule.occurrences(Time.utc(1998, 9, 1))
    expectation = []
    expectation << [5, 12, 19, 26].map { |d| Time.utc(1997, 6, d) }
    expectation << [3, 10, 17, 24, 31].map { |d| Time.utc(1997, 7, d) }
    expectation << [7, 14, 21, 28].map { |d| Time.utc(1997, 8, d) }
    expectation << [4, 11, 18, 25].map { |d| Time.utc(1998, 6, d) }
    expectation << [2, 9, 16, 23, 30].map { |d| Time.utc(1998, 7, d) }
    expectation << [6, 13, 20, 27].map { |d| Time.utc(1998, 8, d) }
    expect(dates).to eq(expectation.flatten)
  end

  it 'should ~ every friday the 13th' do
    start_time = Time.utc(1997, 9, 2)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.monthly.day(:friday).day_of_month(13)
    dates = schedule.occurrences(Time.utc(2000, 10, 13))
    expectation = [
      start_time,
      Time.utc(1998, 2, 13),
      Time.utc(1998, 3, 13),
      Time.utc(1998, 11, 13),
      Time.utc(1999, 8, 13),
      Time.utc(2000, 10, 13),
    ]
    expect(dates).to eq(expectation)
  end

  it 'should ~ the first saturday that follows the first sunday of the month' do
    schedule = IceCube::Schedule.new(Time.utc(1997, 9, 13))
    schedule.add_recurrence_rule IceCube::Rule.monthly.day(:saturday).day_of_month(7, 8, 9, 10, 11, 12, 13)
    dates = schedule.occurrences(Time.utc(1997, 12, 13))
    expectation = [Time.utc(1997, 9, 13), Time.utc(1997, 10, 11), Time.utc(1997, 11, 8), Time.utc(1997, 12, 13)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ every 4 years, the first tuesday after a monday in november (u.s. presidential election day)' do
    schedule = IceCube::Schedule.new(Time.utc(1996, 11, 5))
    schedule.add_recurrence_rule IceCube::Rule.yearly(4).month_of_year(:november).day(:tuesday).day_of_month(2, 3, 4, 5, 6, 7, 8)
    dates = schedule.occurrences(Time.utc(2004, 11, 2))
    expectation = [Time.utc(1996, 11, 5), Time.utc(2000, 11, 7), Time.utc(2004, 11, 2)]
    expect(dates).to eq(expectation)
  end

  it 'should ~ every 3 hours from 9am to 5pm on a specific day' do
    start_time = Time.utc(1997, 9, 2, 9, 0, 0)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.hourly(3).until(Time.utc(1997, 9, 2, 17, 0, 0))
    dates = schedule.all_occurrences
    expect(dates).to eq([Time.utc(1997, 9, 2, 9, 0, 0), Time.utc(1997, 9, 2, 12, 0, 0), Time.utc(1997, 9, 2, 15, 0, 0)])
  end

  it 'should ~ every 15 minutes for 6 occurrences' do
    start_time = Time.utc(1997, 9, 2, 9, 0, 0)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.minutely(15).count(6)
    dates = schedule.all_occurrences
    expect(dates).to eq([Time.utc(1997, 9, 2, 9, 0, 0), Time.utc(1997, 9, 2, 9, 15, 0), Time.utc(1997, 9, 2, 9, 30, 0), Time.utc(1997, 9, 2, 9, 45, 0), Time.utc(1997, 9, 2, 10, 0, 0), Time.utc(1997, 9, 2, 10, 15, 0)])
  end

  it 'should ~ every hour and a half for 4 occurrences' do
    start_time = Time.utc(1997, 9, 2, 9, 0, 0)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.minutely(90).count(4)
    dates = schedule.all_occurrences
    expect(dates).to eq([Time.utc(1997, 9, 2, 9, 0, 0), Time.utc(1997, 9, 2, 10, 30, 0), Time.utc(1997, 9, 2, 12, 0, 0), Time.utc(1997, 9, 2, 13, 30, 0)])
  end

  it 'should ~ every 20 minutes from 9am to 4:40pm every day (a)' do
    start_time = Time.utc(1997, 9, 2, 8, 0, 0)
    end_date = Time.utc(1997, 9, 2, 10, 20, 0)
    schedule = IceCube::Schedule.new(start_time)
    schedule.add_recurrence_rule IceCube::Rule.daily.hour_of_day(9, 10, 11, 12, 13, 14, 15, 16).minute_of_hour(0, 20, 40).until(end_date)
    dates = schedule.all_occurrences
    expecation = [
      start_time,
      Time.utc(1997, 9, 2, 9),
      Time.utc(1997, 9, 2, 9, 20),
      Time.utc(1997, 9, 2, 9, 40),
      Time.utc(1997, 9, 2, 10, 0),
      Time.utc(1997, 9, 2, 10, 20),
    ]
    expect(dates).to eq(expecation)
  end

end

def test_expectations(schedule, dates_array)
  expectation = []
  dates_array.each do |y, months|
    months.each do |m, days|
      days.each do |d|
        expectation << Time.utc(y, m, d)
      end
    end
  end
  # test equality
  expectation.sort!
  expect(schedule.occurrences(expectation.last)).to eq(expectation)
  expectation.each do |date|
    expect(schedule).to be_occurs_at(date)
  end
end
