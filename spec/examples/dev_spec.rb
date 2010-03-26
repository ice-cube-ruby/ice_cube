require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'to_yaml' do
    
  it 'should ~ every 15 minutes for 6 occurrences' do
    start_date = Time.utc(1997, 9, 2, 9, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.minutely(15).count(6)
    dates = schedule.all_occurrences
    dates.should == [Time.utc(1997, 9, 2, 9, 0, 0), Time.utc(1997, 9, 2, 9, 15, 0), Time.utc(1997, 9, 2, 9, 30, 0), Time.utc(1997, 9, 2, 9, 45, 0), Time.utc(1997, 9, 2, 10, 0, 0), Time.utc(1997, 9, 2, 10, 15, 0)]
  end

end