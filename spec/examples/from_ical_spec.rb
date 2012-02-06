require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube, 'from_ical' do

	it 'should return a IceCube DailyRule class for a basic daily rule' do
		rule = IceCube::Rule.from_ical "FREQ=DAILY"
		rule.class.should == IceCube::DailyRule
	end

	it 'should return a IceCube WeeklyRule class for a basic monthly rule' do
		rule = IceCube::Rule.from_ical "FREQ=WEEKLY"
		rule.class.should == IceCube::WeeklyRule
	end

	it 'should return a IceCube MonthlyRule class for a basic monthly rule' do
		rule = IceCube::Rule.from_ical "FREQ=MONTHLY"
		rule.class.should == IceCube::MonthlyRule
	end

	it 'should return a IceCube YearlyRule class for a basic yearly rule' do
		rule = IceCube::Rule.from_ical "FREQ=YEARLY"
		rule.class.should == IceCube::YearlyRule
	end

	it 'should be able to parse a .day rule' do
		rule = IceCube::Rule.from_ical("FREQ=DAILY;BYDAY=MO,TU")
		rule.should == IceCube::Rule.daily.day(:monday, :tuesday)
	end

	it 'should be able to parse a .day_of_week rule' do
		rule = IceCube::Rule.from_ical("FREQ=DAILY;BYDAY=-1TU,-2TU")
    rule.should == IceCube::Rule.daily.day_of_week(:tuesday => [-1, -2])
	end
  
	it 'should be able to parse both .day and .day_of_week rules' do
		rule = IceCube::Rule.from_ical("FREQ=DAILY;BYDAY=MO,-1TU,-2TU")
    rule.should == IceCube::Rule.daily.day_of_week(:tuesday => [-1, -2]).day(:monday)
	end

	it 'should be able to parse a .day_of_month rule' do
		rule = IceCube::Rule.from_ical("FREQ=DAILY;BYMONTHDAY=23")
		rule.should == IceCube::Rule.daily.day_of_month(23)
	end

	it 'should be able to parse a .day_of_year rule' do
		rule = IceCube::Rule.from_ical("FREQ=DAILY;BYYEARDAY=100,200")
		rule.should == IceCube::Rule.daily.day_of_year(100,200)
	end

	it 'should be able to serialize a .month_of_year rule' do
		rule = IceCube::Rule.from_ical("FREQ=DAILY;BYMONTH=1,4")
		rule.should == IceCube::Rule.daily.month_of_year(:january, :april)
	end

	it 'should be able to split to a combination of day_of_week and day (day_of_week has priority)' do
		rule = IceCube::Rule.from_ical("FREQ=DAILY;BYDAY=TU,MO,1MO,-1MO")
		rule.should == IceCube::Rule.daily.day(:tuesday).day_of_week(:monday => [1, -1])
	end

	it 'should be able to parse of .day_of_week rule with multiple days' do
		rule = IceCube::Rule.from_ical("FREQ=DAILY;BYDAY=WE,1MO,-1MO,2TU")
		rule.should == IceCube::Rule.daily.day_of_week(:monday => [1, -1], :tuesday => [2]).day(:wednesday)
	end

	it 'should be able to parse a rule with an until date' do
    t = Time.now.utc
		rule = IceCube::Rule.from_ical("FREQ=WEEKLY;UNTIL=#{t.strftime("%Y%m%dT%H%M%SZ")}")
		rule.to_s.should == IceCube::Rule.weekly.until(t).to_s
	end

	it 'should be able to parse a rule with a count date' do
		rule = IceCube::Rule.from_ical("FREQ=WEEKLY;COUNT=5")
		rule.should == IceCube::Rule.weekly.count(5)
	end

	it 'test' do
		schedule = IceCube::Schedule.new(Time.now)
		schedule.add_recurrence_rule(IceCube::Rule.from_ical("FREQ=DAILY;COUNT=5"))
		#schedule.occurrences_between(Time.now, Time.now + 14.days).count.should == 5
		#schedule.occurrences_between(Time.now, Time.now + 7.days).count.should == 5
		schedule.occurrences_between(Time.now + 7.days, Time.now + 14.days).count.should == 0
	end
end
