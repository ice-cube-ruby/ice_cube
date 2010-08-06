require File.dirname(__FILE__) + '/spec_helper'

require 'active_support'

describe Schedule, 'occurs_on?' do

  it 'should work with occurs_on? with multiple rdates' do
    schedule = Schedule.new(Time.local(2010, 7, 10, 16))
    schedule.add_recurrence_date(Time.local(2010, 7, 11, 16))
    schedule.add_recurrence_date(Time.local(2010, 7, 12, 16))
    schedule.add_recurrence_date(Time.local(2010, 7, 13, 16))
    # test
    schedule.occurs_on?(Date.new(2010, 7, 11)).should be(true)
    schedule.occurs_on?(Date.new(2010, 7, 12)).should be(true)
    schedule.occurs_on?(Date.new(2010, 7, 13)).should be(true)
  end
  
end
