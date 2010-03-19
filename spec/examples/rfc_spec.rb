require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'occurs_on?' do

  it 'should ~ daily for 10 occurrences' do
    schedule = Schedule.new(DateTime.civil(2010, 9, 2))
    schedule.add_recurrence_rule Rule.daily.count(10)
    test_expectations(schedule, {2010 => {9 => [2, 3, 4, 5, 6, 7, 8, 9, 10, 11]}})
  end

  it 'should ~ daily until a certain date' do
    schedule = Schedule.new(DateTime.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.daily.until(DateTime.civil(1997, 12, 24))
    dates = schedule.all_occurrences
    dates.should == (DateTime.civil(1997, 9, 2)..DateTime.civil(1997, 12, 24)).to_a
  end

  it 'should ~ every other day' do
    schedule = Schedule.new(DateTime.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.daily(2).until(DateTime.civil(1997, 12, 24))
    dates = schedule.occurrences(DateTime.civil(1997, 12, -1))
    offset = 0
    (DateTime.civil(1997, 9, 2)..DateTime.civil(1997, 12, 24)).each do |date|
      dates.should include(date) if offset % 2 == 0
      dates.should_not include(date) if offset % 2 != 0
      offset += 1
    end
  end

  it 'should ~ interval 10, count 5' do
    schedule = Schedule.new(DateTime.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.daily(10).count(5)
    dates = schedule.occurrences(DateTime.civil(1998, 1, 1))
    dates.should == [DateTime.civil(1997, 9, 2), DateTime.civil(1997, 9, 12), DateTime.civil(1997, 9, 22), DateTime.civil(1997, 10, 2), DateTime.civil(1997, 10, 12)]
  end

  it 'should ~ everyday in january, for 3 years (a)' do
    schedule = Schedule.new(DateTime.civil(1998, 1, 1))
    schedule.add_recurrence_rule Rule.yearly.until(DateTime.civil(2000, 1, 31)).month_of_year(:january).day(:sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday)
    dates = schedule.occurrences(DateTime.civil(2000, 1, 31))
    dates.each do |date|
      date.month.should == 1
      [1998, 1999, 2000].should include(date.year)
    end
  end

  it 'should ~ everyday in january, for 3 years (b)' do
    schedule = Schedule.new(DateTime.civil(1998, 1, 1))
    schedule.add_recurrence_rule Rule.daily.month_of_year(:january).until(DateTime.civil(2000, 1, 31))
    dates = schedule.occurrences(DateTime.civil(2000, 1, 31))
    dates.each do |date|
      date.month.should == 1
      [1998, 1999, 2000].should include(date.year)
    end
  end
 
  it 'should ~ weekly for 10 occurrences' do
    schedule = Schedule.new(DateTime.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.weekly.count(10)
    dates = schedule.occurrences(DateTime.civil(2000, 1, 1))
    dates.should == [DateTime.civil(1997, 9, 2), DateTime.civil(1997, 9, 9), DateTime.civil(1997, 9, 16), DateTime.civil(1997, 9, 23), DateTime.civil(1997, 9, 30), DateTime.civil(1997, 10, 7), DateTime.civil(1997, 10, 14), DateTime.civil(1997, 10, 21), DateTime.civil(1997, 10, 28), DateTime.civil(1997, 11, 4)]
  end

  it 'should ~ weekly until december 24, 1997' do
    schedule = Schedule.new(DateTime.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.weekly.until(DateTime.civil(1997, 12, 24))
    dates = schedule.occurrences(DateTime.civil(1997, 12, 24))
    #test expectations
    test_expectations(schedule, {1997 => {9 => [2, 9, 16, 23, 30], 10 => [7, 14, 21, 28], 11 => [4, 11, 18, 25], 12 => [2, 9, 16, 23]}})
  end

  it 'should ~ every other week' do
    start_date = DateTime.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly(2)
    dates = schedule.occurrences(DateTime.civil(1997, 12, -1))
    previous_date = dates.shift
    dates.each do |date|
      date.yday.should == previous_date.yday + 14
      previous_date = date
    end
  end

  #
  it 'should ~ weekly on tuesday and thursday for 5 weeks (a)' do
    start_date = DateTime.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.until(DateTime.civil(1997, 10, 6)).day(:tuesday, :thursday)
    dates = schedule.occurrences(DateTime.civil(1997, 12, 1))
    expectation = []
    expectation << [2, 4, 9, 11, 16, 18, 23, 25, 30].map { |d| DateTime.civil(1997, 9, d) }
    expectation << [2].map { |d| DateTime.civil(1997, 10, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ weekly on tuesday and thursday for 5 weeks (b)' do
    start_date = DateTime.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.day(:tuesday, :thursday).count(10)
    dates = schedule.occurrences(DateTime.civil(1997, 12, 1))
    expectation = []
    expectation << [2, 4, 9, 11, 16, 18, 23, 25, 30].map { |d| DateTime.civil(1997, 9, d) }
    expectation << [2].map { |d| DateTime.civil(1997, 10, d) }
    dates.should == expectation.flatten
  end

  #
  it 'should ~ every other week on monday, wednesday and friday until december 24, 1997 but starting on tuesday september 2, 1997' do
    start_date = DateTime.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly(2).until(DateTime.civil(1997, 12, 24)).day(:monday, :wednesday, :friday)
    dates = schedule.occurrences(DateTime.civil(1997, 12, 24))
    expectation = []
    expectation << [3, 5, 15, 17, 19, 29].map { |d| DateTime.civil(1997, 9, d) }
    expectation << [1, 3, 13, 15, 17, 27, 29, 31].map { |d| DateTime.civil(1997, 10, d) }
    expectation << [10, 12, 14, 24, 26, 28].map { |d| DateTime.civil(1997, 11, d) }
    expectation << [8, 10, 12, 22, 24].map { |d| DateTime.civil(1997, 12, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ every other week on tuesday and thursday for 8 occurrences' do
    start_date = DateTime.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly(2).day(:tuesday, :thursday).count(8)
    dates = schedule.occurrences(DateTime.civil(1997, 11, 1))
    expectation = []
    expectation << [2, 4, 16, 18, 30].map { |d| DateTime.civil(1997, 9, d) }
    expectation << [2, 14, 16].map { |d| DateTime.civil(1997, 10, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ monthly on the 1st friday for ten occurrences' do
    start_date = DateTime.civil(1997, 9, 5)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_week(:friday => [1]).count(10)
    dates = schedule.occurrences(DateTime.civil(1998, 7, 1))
    expectation = [DateTime.civil(1997, 9, 5), DateTime.civil(1997, 10, 3), DateTime.civil(1997, 11, 7), DateTime.civil(1997, 12, 5), DateTime.civil(1998, 1, 2), DateTime.civil(1998, 2, 6), DateTime.civil(1998, 3, 6), DateTime.civil(1998, 4, 3), DateTime.civil(1998, 5, 1), DateTime.civil(1998, 6, 5)]
    dates.should == expectation
  end

  it 'should ~ monthly on the first friday until december 24, 1997' do
    start_date = DateTime.civil(1997, 9, 5)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.until(DateTime.civil(1997, 12, 24)).day_of_week(:friday => [1])
    dates = schedule.occurrences(DateTime.civil(1998, 12, 24))
    expectation = [DateTime.civil(1997, 9, 5), DateTime.civil(1997, 10, 3), DateTime.civil(1997, 11, 7), DateTime.civil(1997, 12, 5)]
    dates.should == expectation
  end

  it 'should ~ every other month on the 1st and last sunday of the month for 10 occurrences' do
    start_date = DateTime.civil(1997, 9, 7)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly(2).day_of_week(:sunday => [1, -1]).count(10)
    dates = schedule.occurrences(DateTime.civil(1998, 12, 1))
    expectation = [DateTime.civil(1997, 9, 7), DateTime.civil(1997, 9, 28), DateTime.civil(1997, 11, 2), DateTime.civil(1997, 11, 30), DateTime.civil(1998, 1, 4), DateTime.civil(1998, 1, 25), DateTime.civil(1998, 3, 1), DateTime.civil(1998, 3, 29), DateTime.civil(1998, 5, 3), DateTime.civil(1998, 5, 31)]
    dates.should == expectation
  end

  it 'should ~ monthly on the second to last monday of the month for 6 months' do
    start_date = DateTime.civil(1997, 9, 22)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [-2]).count(6)
    dates = schedule.occurrences(DateTime.civil(1998, 3, 1))
    expectation = [DateTime.civil(1997, 9, 22), DateTime.civil(1997, 10, 20), DateTime.civil(1997, 11, 17), DateTime.civil(1997, 12, 22), DateTime.civil(1998, 1, 19), DateTime.civil(1998, 2, 16)]
    dates.should == expectation
  end

  it 'should ~ monthly on the third to last day of the month, 6 times' do
    start_date = DateTime.civil(1997, 9, 28)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_month(-3).count(6)
    dates = schedule.occurrences(DateTime.civil(1998, 2, 26))
    expectation = [DateTime.civil(1997, 9, 28), DateTime.civil(1997, 10, 29), DateTime.civil(1997, 11, 28), DateTime.civil(1997, 12, 29), DateTime.civil(1998, 1, 29), DateTime.civil(1998, 2, 26)]
    dates.should == expectation
  end

  it 'should ~ monthly on the 2nd and 15th of the month for 10 occurrences' do
    start_date = DateTime.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_month(2, 15).count(10)
    dates = schedule.occurrences(DateTime.civil(1998, 1, 16))
    expectation = [DateTime.civil(1997, 9, 2), DateTime.civil(1997, 9, 15), DateTime.civil(1997, 10, 2), DateTime.civil(1997, 10, 15), DateTime.civil(1997, 11, 2), DateTime.civil(1997, 11, 15), DateTime.civil(1997, 12, 2), DateTime.civil(1997, 12, 15), DateTime.civil(1998, 1, 2), DateTime.civil(1998, 1, 15)]
    dates.should == expectation
  end
  
  it 'should ~ monthly on the 1st and last days of the month for 10 occurrences' do
    start_date = DateTime.civil(1997, 9, 30)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_month(1, -1).count(10)
    dates = schedule.occurrences(DateTime.civil(1998, 2, 2))
    expectation = [DateTime.civil(1997, 9, 30), DateTime.civil(1997, 10, 1), DateTime.civil(1997, 10, 31), DateTime.civil(1997, 11, 1), DateTime.civil(1997, 11, 30), DateTime.civil(1997, 12, 1), DateTime.civil(1997, 12, 31), DateTime.civil(1998, 1, 1), DateTime.civil(1998, 1, 31), DateTime.civil(1998, 2, 1)]
    dates.should == expectation
  end

  it 'should ~ every 18 months on the 10th through the 15th of the month for 10 occurrences' do
    schedule = Schedule.new(DateTime.civil(1997, 9, 10))
    schedule.add_recurrence_rule Rule.monthly(18).day_of_month(10, 11, 12, 13, 14, 15).count(10)
    dates = schedule.occurrences(DateTime.civil(1999, 12, 1))
    expectation = []
    expectation << [10, 11, 12, 13, 14, 15].map { |d| DateTime.civil(1997, 9, d) }
    expectation << [10, 11, 12, 13].map { |d| DateTime.civil(1999, 3, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ every tuesday, every other month' do
    schedule = Schedule.new(DateTime.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.monthly(2).day(:tuesday)
    dates = schedule.occurrences(DateTime.civil(1998, 4, 1))
    expectation = []
    expectation << [2, 9, 16, 23, 30].map { |d| DateTime.civil(1997, 9, d) }
    expectation << [4, 11, 18, 25].map { |d| DateTime.civil(1997, 11, d) }
    expectation << [6, 13, 20, 27].map { |d| DateTime.civil(1998, 1, d) }
    expectation << [3, 10, 17, 24, 31].map { |d| DateTime.civil(1998, 3, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ yearly in june and july for 10 occurrences' do
    schedule = Schedule.new(DateTime.civil(1997, 6, 10))
    schedule.add_recurrence_rule Rule.yearly.month_of_year(:june, :july).count(10)
    dates = schedule.occurrences(DateTime.civil(2001, 8, 1))
    expectation = []
    (1997..2001).each do |year|
      expectation << DateTime.civil(year, 6, 10)
      expectation << DateTime.civil(year, 7, 10)
    end
    dates.should == expectation.flatten
  end

  it 'should ~ every other year on january, feburary, and march for 10 occurrences' do
    schedule = Schedule.new(DateTime.civil(1997, 3, 10))
    schedule.add_recurrence_rule Rule.yearly(2).month_of_year(:january, :february, :march).count(10)
    dates = schedule.occurrences(DateTime.civil(2003, 4, 1))
    expectation = [DateTime.civil(1997, 3, 10), DateTime.civil(1999, 1, 10), DateTime.civil(1999, 2, 10), DateTime.civil(1999, 3, 10), DateTime.civil(2001, 1, 10), DateTime.civil(2001, 2, 10), DateTime.civil(2001, 3, 10), DateTime.civil(2003, 1, 10), DateTime.civil(2003, 2, 10), DateTime.civil(2003, 3, 10)]
    dates.should == expectation
  end

  it 'should ~ every third year on the 1st, 100th and 200th day for 10 occurrences' do
    schedule = Schedule.new(DateTime.civil(1997, 1, 1))
    schedule.add_recurrence_rule Rule.yearly(3).day_of_year(1, 100, 200).count(10)
    dates = schedule.occurrences(DateTime.civil(2006, 1, 2))
    expectation = [DateTime.civil(1997, 1, 1), DateTime.civil(1997, 4, 10), DateTime.civil(1997, 7, 19), DateTime.civil(2000, 1, 1), DateTime.civil(2000, 4, 9), DateTime.civil(2000, 7, 18), DateTime.civil(2003, 1, 1), DateTime.civil(2003, 4, 10), DateTime.civil(2003, 7, 19), DateTime.civil(2006, 1, 1)]
    dates.should == expectation
  end

  it 'should ~ every thursday in march, forever' do
    schedule = Schedule.new(DateTime.civil(1997, 3, 13))
    schedule.add_recurrence_rule Rule.yearly.month_of_year(:march).day(:thursday)
    dates = schedule.occurrences(DateTime.civil(1999, 3, 25))
    expectation = []
    expectation << [13, 20, 27].map { |d| DateTime.civil(1997, 3, d) }
    expectation << [5, 12, 19, 26].map { |d| DateTime.civil(1998, 3, d) }
    expectation << [4, 11, 18, 25].map { |d| DateTime.civil(1999, 3, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ every thursday, but only during june, july, and august' do
    schedule = Schedule.new(DateTime.civil(1997, 6, 5))
    schedule.add_recurrence_rule Rule.yearly.day(:thursday).month_of_year(:june, :july, :august)
    dates = schedule.occurrences(DateTime.civil(1998, 9, 1))
    expectation = []
    expectation << [5, 12, 19, 26].map { |d| DateTime.civil(1997, 6, d) }
    expectation << [3, 10, 17, 24, 31].map { |d| DateTime.civil(1997, 7, d) }
    expectation << [7, 14, 21, 28].map { |d| DateTime.civil(1997, 8, d) }
    expectation << [4, 11, 18, 25].map { |d| DateTime.civil(1998, 6, d) }
    expectation << [2, 9, 16, 23, 30].map { |d| DateTime.civil(1998, 7, d) }
    expectation << [6, 13, 20, 27].map { |d| DateTime.civil(1998, 8, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ every friday the 13th' do
    schedule = Schedule.new(DateTime.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.monthly.day(:friday).day_of_month(13)
    dates = schedule.occurrences(DateTime.civil(2000, 10, 13))
    expectation = [DateTime.civil(1998, 2, 13), DateTime.civil(1998, 3, 13), DateTime.civil(1998, 11, 13), DateTime.civil(1999, 8, 13), DateTime.civil(2000, 10, 13)]
    dates.should == expectation
  end

  it 'should ~ the first saturday that follows the first sunday of the month' do
    schedule = Schedule.new(DateTime.civil(1997, 9, 13))
    schedule.add_recurrence_rule Rule.monthly.day(:saturday).day_of_month(7, 8, 9, 10, 11, 12, 13)
    dates = schedule.occurrences(DateTime.civil(1997, 12, 13))
    expectation = [DateTime.civil(1997, 9, 13), DateTime.civil(1997, 10, 11), DateTime.civil(1997, 11, 8), DateTime.civil(1997, 12, 13)]
    dates.should == expectation
  end

  it 'should ~ every 4 years, the first tuesday after a monday in november (u.s. presidential election day)' do
    schedule = Schedule.new(DateTime.civil(1996, 11, 5))
    schedule.add_recurrence_rule Rule.yearly(4).month_of_year(:november).day(:tuesday).day_of_month(2, 3, 4, 5, 6, 7, 8)
    dates = schedule.occurrences(DateTime.civil(2004, 11, 2))
    expectation = [DateTime.civil(1996, 11, 5), DateTime.civil(2000, 11, 7), DateTime.civil(2004, 11, 2)]
    dates.should == expectation
  end
  
end
