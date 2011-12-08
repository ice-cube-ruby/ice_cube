require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube do

  it 'should be able to calculate end of dates without active_support' do
    date = Date.new(2011, 1, 1)
    date.should_receive(:respond_to?).with(:end_of_day).and_return(false)
    res = [ IceCube::TimeUtil.end_of_date(date), Time.local(2011, 1, 1, 23, 59, 59) ]
    res.all? { |r| r.class.name == 'Time' }
    res.map(&:to_s).uniq.size.should == 1
  end

  it 'should be able to calculate beginning of dates without active_support' do
    date = Date.new(2011, 1, 1)
    date.should_receive(:respond_to?).with(:beginning_of_day).and_return(false)
    res = [ IceCube::TimeUtil.beginning_of_date(date), Time.local(2011, 1, 1, 0, 0, 0) ]
    res.all? { |r| r.class.name == 'Time' }
    res.map(&:to_s).uniq.size.should == 1
  end

end
