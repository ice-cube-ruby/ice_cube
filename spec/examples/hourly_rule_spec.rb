require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe HourlyRule do


    it 'should produce the correct days for @interval = 3' do
      start_date = DAY
      schedule = Schedule.new(start_date)
      schedule = Schedule.from_yaml(schedule.to_yaml)
      schedule.add_recurrence_rule Rule.hourly(3)
      #check assumption (3) -- (1) 2 (3) 4 (5) 6
      dates = schedule.first(3)
      dates.size.should == 3
      dates.should == [DAY, DAY + 3 * ONE_HOUR, DAY + 6 * ONE_HOUR]
    end

  end
end
