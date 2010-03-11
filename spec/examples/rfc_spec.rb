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

#  it 'should ~ everyday in january, for 3 years (b)' do
#    schedule = Schedule.new(Date.civil(1998, 1, 1))
#    schedule.add_recurrence_rule Rule.daily.month_of_year(:january).until(Date.civil(2000, 1, 31))
#    dates = schedule.occurrences(Date.civil(2000, 1, 31))
#    dates.each do |date|
#      date.month.should == 1
#      [1998, 1999, 2000].should include(date.year)
#    end
#  end
  
end
