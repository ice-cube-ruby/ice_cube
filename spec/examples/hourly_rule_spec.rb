require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::HourlyRule do

  it 'should not produce results for @interval = 0' do
    start_date = DAY
    schedule = IceCube::Schedule.new(start_date)
    schedule = IceCube::Schedule.from_yaml(schedule.to_yaml)
    schedule.add_recurrence_rule IceCube::Rule.hourly(0)
    #check assumption
    dates = schedule.first(3)
    dates.size.should == 0
    dates.should == []
  end

  it 'should produce the correct days for @interval = 3' do
    start_date = DAY
    schedule = IceCube::Schedule.new(start_date)
    schedule = IceCube::Schedule.from_yaml(schedule.to_yaml)
    schedule.add_recurrence_rule IceCube::Rule.hourly(3)
    #check assumption (3) -- (1) 2 (3) 4 (5) 6
    dates = schedule.first(3)
    dates.size.should == 3
    dates.should == [DAY, DAY + 3 * IceCube::ONE_HOUR, DAY + 6 * IceCube::ONE_HOUR]
  end

end
