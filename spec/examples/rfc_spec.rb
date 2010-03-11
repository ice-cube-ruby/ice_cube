require 'ice_cube.rb'
include IceCube

describe Schedule, 'occurs_on?' do

  it 'should ~ daily for 10 occurrences' do
    schedule = Schedule.new(Date.civil(2010, 9, 2))
    schedule.add_recurrence_rule Rule.daily.count(10)
    dates = schedule.occurrences(Date.civil(2011, 1, 1))
    dates.should == (Date.civil(2010, 9, 2)..Date.civil(2010, 9, 11)).to_a
  end

  it 'should ~ daily until a certain date' do
    schedule = Schedule.new(Date.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.daily.until(Date.civil(1997, 12, 24))
    dates = schedule.occurrences(Date.civil(1997, 12, -1))
    dates.should == (Date.civil(1997, 9, 2)..Date.civil(1997, 12, 24)).to_a
  end

  it 'should ~ every other day' do
    schedule = Schedule.new(Date.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.daily(2).until(Date.civil(1997, 12, 24))
    dates = schedule.occurrences(Date.civil(1997, 12, -1))
    offset = 0
    (Date.civil(1997, 9, 2)..Date.civil(1997, 12, 24)).each do |date|
      dates.should include(date) if offset % 2 == 0
      dates.should_not include(date) if offset % 2 != 0
      offset += 1
    end
  end

  it 'should ~ interval 10, count 5' do
    schedule = Schedule.new(Date.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.daily(10).count(5)
    dates = schedule.occurrences(Date.civil(1998, 1, 1))
    dates.should == [Date.civil(1997, 9, 2), Date.civil(1997, 9, 12), Date.civil(1997, 9, 22), Date.civil(1997, 10, 2), Date.civil(1997, 10, 12)]
  end

  it 'should ~ everyday in january, for 3 years (a)' do
    schedule = Schedule.new(Date.civil(1998, 1, 1))
    schedule.add_recurrence_rule Rule.yearly.until(Date.civil(2000, 1, 31)).month_of_year(:january).day(:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday)
    dates = schedule.occurrences(Date.civil(2000, 1, 31))
    dates.each do |date|
      date.month.should == 1
      [1998, 1999, 2000].should include(date.year)
    end
  end

  it 'should ~ everyday in january, for 3 years (b)' do
    schedule = Schedule.new(Date.civil(1998, 1, 1))
    schedule.add_recurrence_rule Rule.daily.month_of_year(:january).until(Date.civil(2000, 1, 31))
    dates = schedule.occurrences(Date.civil(2000, 1, 31))
    dates.each do |date|
      date.month.should == 1
      [1998, 1999, 2000].should include(date.year)
    end
  end

  it 'should ~ weekly for 10 occurrences' do
    schedule = Schedule.new(Date.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.weekly.count(10)
    dates = schedule.occurrences(Date.civil(2000, 1, 1))
    dates.should == [Date.civil(1997, 9, 2), Date.civil(1997, 9, 9), Date.civil(1997, 9, 16), Date.civil(1997, 9, 23), Date.civil(1997, 9, 30), Date.civil(1997, 10, 7), Date.civil(1997, 10, 14), Date.civil(1997, 10, 21), Date.civil(1997, 10, 28), Date.civil(1997, 11, 4)]
  end

  it 'should ~ weekly until december 24, 1997' do
    schedule = Schedule.new(Date.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.weekly.until(Date.civil(1997, 12, 24))
    dates = schedule.occurrences(Date.civil(1997, 12, 24))
    expectation = []
    expectation << [2, 9, 16, 23, 30].map { |d| Date.civil(1997, 9, d) }
    expectation << [7, 14, 21, 28].map { |d| Date.civil(1997, 10, d) }
    expectation << [4, 11, 18, 25].map { |d| Date.civil(1997, 11, d) }
    expectation << [2, 9, 16, 23].map { |d| Date.civil(1997, 12, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ every other week' do
    start_date = Date.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly(2)
    dates = schedule.occurrences(Date.civil(1997, 12, -1))
    dates.each do |date|
      (last_date = date; next) unless last_date
      date.yday.should == last_date.yday + 14
      last_date = date
    end
  end

  #
  it 'should ~ weekly on tuesday and thursday for 5 weeks (a)' do
    start_date = Date.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.until(Date.civil(1997, 10, 6)).day(:tuesday, :thursday)
    dates = schedule.occurrences(Date.civil(1997, 12, 1))
    expectation = []
    expectation << [2, 4, 9, 11, 16, 18, 23, 25, 30].map { |d| Date.civil(1997, 9, d) }
    expectation << [2].map { |d| Date.civil(1997, 10, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ weekly on tuesday and thursday for 5 weeks (b)' do
    start_date = Date.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.count(10).day(:tuesday, :thursday)
    dates = schedule.occurrences(Date.civil(1997, 12, 1))
    expectation = []
    expectation << [2, 4, 9, 11, 16, 18, 23, 25, 30].map { |d| Date.civil(1997, 9, d) }
    expectation << [2].map { |d| Date.civil(1997, 10, d) }
    dates.should == expectation.flatten
  end

  #
  it 'should ~ every other week on monday, wednesday and friday until december 24, 1997 but starting on tuesday september 2, 1997' do
    start_date = Date.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly(2).until(Date.civil(1997, 12, 24)).day(:monday, :wednesday, :friday)
    dates = schedule.occurrences(Date.civil(1997, 12, 24))
    expectation = []
    expectation << [3, 5, 15, 17, 19, 29].map { |d| Date.civil(1997, 9, d) }
    expectation << [1, 3, 13, 15, 17, 27, 29, 31].map { |d| Date.civil(1997, 10, d) }
    expectation << [10, 12, 14, 24, 26, 28].map { |d| Date.civil(1997, 11, d) }
    expectation << [8, 10, 12, 22, 24].map { |d| Date.civil(1997, 12, d) }
    dates.should == expectation.flatten
  end
  
end
