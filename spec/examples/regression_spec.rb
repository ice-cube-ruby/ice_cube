require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube do

  it 'should consider recurrence dates properly in find_occurreces - github issue 43' do
    s = IceCube::Schedule.new(Time.new(2011,10,1, 18, 25))
    s.add_recurrence_date(Time.new(2011,12,3,15,0,0))
    s.add_recurrence_date(Time.new(2011,12,3,10,0,0)) 
    s.add_recurrence_date(Time.new(2011,12,4,10,0,0))
    s.occurs_at?(Time.new(2011,12,3,15,0,0)).should be_true
  end

end
