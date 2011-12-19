require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube, 'from_ical' do

	it 'should return a IceCube DailyRule class for a basic daily rule' do
		rule = IceCube::Rule
		rule.from_ical = "FREQ=DAILY"
		rule.class.should == IceCube::DailyRule
	end

	it 'should return a IceCube WeeklyRule class for a basic monthly rule' do
		rule = IceCube::Rule
		rule.from_ical = "FREQ=WEEKLY"
		rule.class.should == IceCube::WeeklyRule
	end

	it 'should return a IceCube MonthlyRule class for a basic monthly rule' do
		rule = IceCube::Rule
		rule.from_ical = "FREQ=MONTHLY"
		rule.class.should == IceCube::MonthlyRule
	end

	it 'should return a IceCube YearlyRule class for a basic yearly rule' do
		rule = IceCube::Rule
		rule.from_ical = "FREQ=YEARLY"
		rule.class.should == IceCube::YearlyRule
	end

end
