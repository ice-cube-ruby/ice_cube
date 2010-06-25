require File.dirname(__FILE__) + '/spec_helper'

describe Schedule, 'occurs_on?' do

  it 'local - should make dates on interval over dst - github issue 4' do
    start_date = Time.local(2010, 3, 12, 19, 0, 0)
    schedule = Schedule.new(start_date)
    schedule.add_recurrence_rule Rule.daily(3)
    schedule.first(3).should == [Time.local(2010, 3, 12, 19, 0, 0), Time.local(2010, 3, 15, 19, 0, 0), Time.local(2010, 3, 18, 19, 0, 0)]
  end
  
end
