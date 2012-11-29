require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube do

  before do
    Time.any_instance.should_receive(:respond_to?).with(:time_zone).at_least(:once).and_return(false)
  end

  it 'should be able to calculate end of dates without active_support' do
    date = Date.new(2011, 1, 1)
    res = [ IceCube::TimeUtil.end_of_date(date), Time.local(2011, 1, 1, 23, 59, 59) ]
    res.all? { |r| r.class.name == 'Time' }
    res.map(&:to_s).uniq.size.should == 1
  end

  it 'should be able to calculate beginning of dates without active_support' do
    date = Date.new(2011, 1, 1)
    res = [ IceCube::TimeUtil.beginning_of_date(date), Time.local(2011, 1, 1, 0, 0, 0) ]
    res.all? { |r| r.class.name == 'Time' }
    res.map(&:to_s).uniq.size.should == 1
  end

end
