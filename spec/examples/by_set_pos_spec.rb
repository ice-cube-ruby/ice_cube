require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe MonthlyRule, 'BYSETPOS' do
    it 'should behave correctly' do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYDAY=WE;BYSETPOS=4"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 01, 01))).
        to eq([
          Time.new(2015,6,24,12,0,0),
          Time.new(2015,7,22,12,0,0),
          Time.new(2015,8,26,12,0,0),
          Time.new(2015,9,23,12,0,0)
        ])
    end
  end

  describe YearlyRule, 'BYSETPOS' do
    it 'should behave correctly' do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1"
      schedule.start_time = Time.new(1966,7,5)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 01, 01))).
        to eq([
          Time.new(2015, 7, 31),
          Time.new(2016, 7, 31)
        ])
    end
  end
end
