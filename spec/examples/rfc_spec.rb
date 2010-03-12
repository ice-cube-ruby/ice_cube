require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'occurs_on?' do

  # 10
  it 'should ~ daily for 10 occurrences' do
    schedule = Schedule.new(Date.civil(2010, 9, 2))
    schedule.add_recurrence_rule Rule.daily
    dates = schedule.occurrences(Date.civil(2011, 1, 1))
    dates.slice(0, 10).should == (Date.civil(2010, 9, 2)..Date.civil(2010, 9, 11)).to_a
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

  # 5
  it 'should ~ interval 10, count 5' do
    schedule = Schedule.new(Date.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.daily(10)
    dates = schedule.occurrences(Date.civil(1998, 1, 1))
    dates.slice(0, 5).should == [Date.civil(1997, 9, 2), Date.civil(1997, 9, 12), Date.civil(1997, 9, 22), Date.civil(1997, 10, 2), Date.civil(1997, 10, 12)]
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
 
  #10
  it 'should ~ weekly for 10 occurrences' do
    schedule = Schedule.new(Date.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.weekly
    dates = schedule.occurrences(Date.civil(2000, 1, 1))
    dates.slice(0, 10).should == [Date.civil(1997, 9, 2), Date.civil(1997, 9, 9), Date.civil(1997, 9, 16), Date.civil(1997, 9, 23), Date.civil(1997, 9, 30), Date.civil(1997, 10, 7), Date.civil(1997, 10, 14), Date.civil(1997, 10, 21), Date.civil(1997, 10, 28), Date.civil(1997, 11, 4)]
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
    previous_date = dates.shift
    dates.each do |date|
      date.yday.should == previous_date.yday + 14
      previous_date = date
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

  #10
  it 'should ~ weekly on tuesday and thursday for 5 weeks (b)' do
    start_date = Date.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly.day(:tuesday, :thursday)
    dates = schedule.occurrences(Date.civil(1997, 12, 1))
    expectation = []
    expectation << [2, 4, 9, 11, 16, 18, 23, 25, 30].map { |d| Date.civil(1997, 9, d) }
    expectation << [2].map { |d| Date.civil(1997, 10, d) }
    dates.slice(0, 10).should == expectation.flatten
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

  #8
  it 'should ~ every other week on tuesday and thursday for 8 occurrences' do
    start_date = Date.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.weekly(2).day(:tuesday, :thursday)
    dates = schedule.occurrences(Date.civil(1997, 11, 1))
    expectation = []
    expectation << [2, 4, 16, 18, 30].map { |d| Date.civil(1997, 9, d) }
    expectation << [2, 14, 16].map { |d| Date.civil(1997, 10, d) }
    dates.slice(0, 8).should == expectation.flatten
  end

  #10
  it 'should ~ monthly on the 1st friday for ten occurrences' do
    start_date = Date.civil(1997, 9, 5)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_week(:friday => [1])
    dates = schedule.occurrences(Date.civil(1998, 7, 1))
    expectation = [Date.civil(1997, 9, 5), Date.civil(1997, 10, 3), Date.civil(1997, 11, 7), Date.civil(1997, 12, 5), Date.civil(1998, 1, 2), Date.civil(1998, 2, 6), Date.civil(1998, 3, 6), Date.civil(1998, 4, 3), Date.civil(1998, 5, 1), Date.civil(1998, 6, 5)]
    dates.slice(0, 10).should == expectation
  end

  it 'should ~ monthly on the first friday until december 24, 1997' do
    start_date = Date.civil(1997, 9, 5)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.until(Date.civil(1997, 12, 24)).day_of_week(:friday => [1])
    dates = schedule.occurrences(Date.civil(1998, 12, 24))
    expectation = [Date.civil(1997, 9, 5), Date.civil(1997, 10, 3), Date.civil(1997, 11, 7), Date.civil(1997, 12, 5)]
    dates.should == expectation
  end

  #10
  it 'should ~ every other month on the 1st and last sunday of the month for 10 occurrences' do
    start_date = Date.civil(1997, 9, 7)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly(2).day_of_week(:sunday => [1, -1])
    dates = schedule.occurrences(Date.civil(1998, 12, 1))
    expectation = [Date.civil(1997, 9, 7), Date.civil(1997, 9, 28), Date.civil(1997, 11, 2), Date.civil(1997, 11, 30), Date.civil(1998, 1, 4), Date.civil(1998, 1, 25), Date.civil(1998, 3, 1), Date.civil(1998, 3, 29), Date.civil(1998, 5, 3), Date.civil(1998, 5, 31)]
    dates.slice(0, 10).should == expectation
  end

  #6
  it 'should ~ monthly on the second to last monday of the month for 6 months' do
    start_date = Date.civil(1997, 9, 22)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_week(:monday => [-2])
    dates = schedule.occurrences(Date.civil(1998, 3, 1))
    expectation = [Date.civil(1997, 9, 22), Date.civil(1997, 10, 20), Date.civil(1997, 11, 17), Date.civil(1997, 12, 22), Date.civil(1998, 1, 19), Date.civil(1998, 2, 16)]
    dates.slice(0, 6).should == expectation
  end

  # 6
  it 'should ~ monthly on the third to last day of the month, 6 times' do
    start_date = Date.civil(1997, 9, 28)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_month(-3)
    dates = schedule.occurrences(Date.civil(1998, 2, 26))
    expectation = [Date.civil(1997, 9, 28), Date.civil(1997, 10, 29), Date.civil(1997, 11, 28), Date.civil(1997, 12, 29), Date.civil(1998, 1, 29), Date.civil(1998, 2, 26)]
    dates.slice(0, 6).should == expectation
  end

  #10
  it 'should ~ monthly on the 2nd and 15th of the month for 10 occurrences' do
    start_date = Date.civil(1997, 9, 2)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_month(2, 15)
    dates = schedule.occurrences(Date.civil(1998, 1, 16))
    expectation = [Date.civil(1997, 9, 2), Date.civil(1997, 9, 15), Date.civil(1997, 10, 2), Date.civil(1997, 10, 15), Date.civil(1997, 11, 2), Date.civil(1997, 11, 15), Date.civil(1997, 12, 2), Date.civil(1997, 12, 15), Date.civil(1998, 1, 2), Date.civil(1998, 1, 15)]
    dates.slice(0, 10).should == expectation
  end
  
  #10
  it 'should ~ monthly on the 1st and last days of the month for 10 occurrences' do
    start_date = Date.civil(1997, 9, 30)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.monthly.day_of_month(1, -1)
    dates = schedule.occurrences(Date.civil(1998, 2, 2))
    expectation = [Date.civil(1997, 9, 30), Date.civil(1997, 10, 1), Date.civil(1997, 10, 31), Date.civil(1997, 11, 1), Date.civil(1997, 11, 30), Date.civil(1997, 12, 1), Date.civil(1997, 12, 31), Date.civil(1998, 1, 1), Date.civil(1998, 1, 31), Date.civil(1998, 2, 1)]
    dates.slice(0, 10).should == expectation
  end

  #10
  it 'should ~ every 18 months on the 10th through the 15th of the month for 10 occurrences' do
    schedule = Schedule.new(Date.civil(1997, 9, 10))
    schedule.add_recurrence_rule Rule.monthly(18).day_of_month(10, 11, 12, 13, 14, 15)
    dates = schedule.occurrences(Date.civil(1999, 12, 1))
    expectation = []
    expectation << [10, 11, 12, 13, 14, 15].map { |d| Date.civil(1997, 9, d) }
    expectation << [10, 11, 12, 13].map { |d| Date.civil(1999, 3, d) }
    dates.slice(0, 10).should == expectation.flatten
  end

  it 'should ~ every tuesday, every other month' do
    schedule = Schedule.new(Date.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.monthly(2).day(:tuesday)
    dates = schedule.occurrences(Date.civil(1998, 4, 1))
    expectation = []
    expectation << [2, 9, 16, 23, 30].map { |d| Date.civil(1997, 9, d) }
    expectation << [4, 11, 18, 25].map { |d| Date.civil(1997, 11, d) }
    expectation << [6, 13, 20, 27].map { |d| Date.civil(1998, 1, d) }
    expectation << [3, 10, 17, 24, 31].map { |d| Date.civil(1998, 3, d) }
    dates.should == expectation.flatten
  end

  #10
  it 'should ~ yearly in june and july for 10 occurrences' do
    schedule = Schedule.new(Date.civil(1997, 6, 10))
    schedule.add_recurrence_rule Rule.yearly.month_of_year(:june, :july)
    dates = schedule.occurrences(Date.civil(2001, 8, 1))
    expectation = []
    (1997..2001).each do |year|
      expectation << Date.civil(year, 6, 10)
      expectation << Date.civil(year, 7, 10)
    end
    dates.slice(0, 10).should == expectation.flatten
  end

  #10
  it 'should ~ every other year on january, feburary, and march for 10 occurrences' do
    schedule = Schedule.new(Date.civil(1997, 3, 10))
    schedule.add_recurrence_rule Rule.yearly(2).month_of_year(:january, :february, :march)
    dates = schedule.occurrences(Date.civil(2003, 4, 1))
    expectation = [Date.civil(1997, 3, 10), Date.civil(1999, 1, 10), Date.civil(1999, 2, 10), Date.civil(1999, 3, 10), Date.civil(2001, 1, 10), Date.civil(2001, 2, 10), Date.civil(2001, 3, 10), Date.civil(2003, 1, 10), Date.civil(2003, 2, 10), Date.civil(2003, 3, 10)]
    dates.slice(0, 10).should == expectation
  end

  #10
  it 'should ~ every third year on the 1st, 100th and 200th day for 10 occurrences' do
    schedule = Schedule.new(Date.civil(1997, 1, 1))
    schedule.add_recurrence_rule Rule.yearly(3).day_of_year(1, 100, 200)
    dates = schedule.occurrences(Date.civil(2006, 1, 2))
    expectation = [Date.civil(1997, 1, 1), Date.civil(1997, 4, 10), Date.civil(1997, 7, 19), Date.civil(2000, 1, 1), Date.civil(2000, 4, 9), Date.civil(2000, 7, 18), Date.civil(2003, 1, 1), Date.civil(2003, 4, 10), Date.civil(2003, 7, 19), Date.civil(2006, 1, 1)]
    dates.slice(0, 10).should == expectation
  end

  it 'should ~ every thursday in march, forever' do
    schedule = Schedule.new(Date.civil(1997, 3, 13))
    schedule.add_recurrence_rule Rule.yearly.month_of_year(:march).day(:thursday)
    dates = schedule.occurrences(Date.civil(1999, 3, 25))
    expectation = []
    expectation << [13, 20, 27].map { |d| Date.civil(1997, 3, d) }
    expectation << [5, 12, 19, 26].map { |d| Date.civil(1998, 3, d) }
    expectation << [4, 11, 18, 25].map { |d| Date.civil(1999, 3, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ every thursday, but only during june, july, and august' do
    schedule = Schedule.new(Date.civil(1997, 6, 5))
    schedule.add_recurrence_rule Rule.yearly.day(:thursday).month_of_year(:june, :july, :august)
    dates = schedule.occurrences(Date.civil(1998, 9, 1))
    expectation = []
    expectation << [5, 12, 19, 26].map { |d| Date.civil(1997, 6, d) }
    expectation << [3, 10, 17, 24, 31].map { |d| Date.civil(1997, 7, d) }
    expectation << [7, 14, 21, 28].map { |d| Date.civil(1997, 8, d) }
    expectation << [4, 11, 18, 25].map { |d| Date.civil(1998, 6, d) }
    expectation << [2, 9, 16, 23, 30].map { |d| Date.civil(1998, 7, d) }
    expectation << [6, 13, 20, 27].map { |d| Date.civil(1998, 8, d) }
    dates.should == expectation.flatten
  end

  it 'should ~ every friday the 13th' do
    schedule = Schedule.new(Date.civil(1997, 9, 2))
    schedule.add_recurrence_rule Rule.monthly.day(:friday).day_of_month(13)
    dates = schedule.occurrences(Date.civil(2000, 10, 13))
    expectation = [Date.civil(1998, 2, 13), Date.civil(1998, 3, 13), Date.civil(1998, 11, 13), Date.civil(1999, 8, 13), Date.civil(2000, 10, 13)]
    dates.should == expectation
  end

  it 'should ~ the first saturday that follows the first sunday of the month' do
    schedule = Schedule.new(Date.civil(1997, 9, 13))
    schedule.add_recurrence_rule Rule.monthly.day(:saturday).day_of_month(7, 8, 9, 10, 11, 12, 13)
    dates = schedule.occurrences(Date.civil(1997, 12, 13))
    expectation = [Date.civil(1997, 9, 13), Date.civil(1997, 10, 11), Date.civil(1997, 11, 8), Date.civil(1997, 12, 13)]
    dates.should == expectation
  end

  it 'should ~ every 4 years, the first tuesday after a monday in november (u.s. presidential election day)' do
    schedule = Schedule.new(Date.civil(1996, 11, 5))
    schedule.add_recurrence_rule Rule.yearly(4).month_of_year(:november).day(:tuesday).day_of_month(2, 3, 4, 5, 6, 7, 8)
    dates = schedule.occurrences(Date.civil(2004, 11, 2))
    expectation = [Date.civil(1996, 11, 5), Date.civil(2000, 11, 7), Date.civil(2004, 11, 2)]
    dates.should == expectation
  end
  
end
