require File.dirname(__FILE__) + "/../spec_helper"

describe IceCube::Schedule, "to_s" do
  shared_examples "to_s in English" do
    it "should represent its start time by default" do
      t0 = Time.local(2013, 2, 14)
      expect(IceCube::Schedule.new(t0).to_s).to eq("February 14, 2013")
    end

    it "should have a useful base to_s representation for a secondly rule" do
      expect(IceCube::Rule.secondly.to_s).to eq("Secondly")
      expect(IceCube::Rule.secondly(2).to_s).to eq("Every 2 seconds")
    end

    it "should have a useful base to_s representation for a minutely rule" do
      expect(IceCube::Rule.minutely.to_s).to eq("Minutely")
      expect(IceCube::Rule.minutely(2).to_s).to eq("Every 2 minutes")
    end

    it "should have a useful base to_s representation for a hourly rule" do
      expect(IceCube::Rule.hourly.to_s).to eq("Hourly")
      expect(IceCube::Rule.hourly(2).to_s).to eq("Every 2 hours")
    end

    it "should have a useful base to_s representation for a daily rule" do
      expect(IceCube::Rule.daily.to_s).to eq("Daily")
      expect(IceCube::Rule.daily(2).to_s).to eq("Every 2 days")
    end

    it "should have a useful base to_s representation for a weekly rule" do
      expect(IceCube::Rule.weekly.to_s).to eq("Weekly")
      expect(IceCube::Rule.weekly(2).to_s).to eq("Every 2 weeks")
    end

    it "should have a useful base to_s representation for a monthly rule" do
      expect(IceCube::Rule.monthly.to_s).to eq("Monthly")
      expect(IceCube::Rule.monthly(2).to_s).to eq("Every 2 months")
    end

    it "should have a useful base to_s representation for a yearly rule" do
      expect(IceCube::Rule.yearly.to_s).to eq("Yearly")
      expect(IceCube::Rule.yearly(2).to_s).to eq("Every 2 years")
    end

    it "should work with various sentence types properly" do
      expect(IceCube::Rule.weekly.to_s).to eq("Weekly")
      expect(IceCube::Rule.weekly.day(:monday).to_s).to eq("Weekly on Mondays")
      expect(IceCube::Rule.weekly.day(:monday, :tuesday).to_s).to eq("Weekly on Mondays and Tuesdays")
      expect(IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s).to eq("Weekly on Mondays, Tuesdays, and Wednesdays")
    end

    it "should show saturday and sunday as weekends" do
      expect(IceCube::Rule.weekly.day(:saturday, :sunday).to_s).to eq("Weekly on Weekends")
    end

    it "should not show saturday and sunday as weekends when other days are present also" do
      expect(IceCube::Rule.weekly.day(:sunday, :monday, :saturday).to_s).to eq(
        "Weekly on Sundays, Mondays, and Saturdays"
      )
    end

    it "should reorganize days to be in order" do
      expect(IceCube::Rule.weekly.day(:tuesday, :monday).to_s).to eq(
        "Weekly on Mondays and Tuesdays"
      )
    end

    it "should show weekdays as such" do
      expect(IceCube::Rule.weekly.day(
        :monday, :tuesday, :wednesday,
        :thursday, :friday
      ).to_s).to eq("Weekly on Weekdays")
    end

    it "should not show weekdays as such when a weekend day is present" do
      expect(IceCube::Rule.weekly.day(
        :sunday, :monday, :tuesday, :wednesday,
        :thursday, :friday
      ).to_s).to eq("Weekly on Sundays, Mondays, Tuesdays, Wednesdays, Thursdays, and Fridays")
    end

    it "should show start time for an empty schedule" do
      schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
      expect(schedule.to_s).to eq("March 20, 2010")
    end

    it "should work with a single date" do
      schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
      schedule.add_recurrence_time Time.local(2010, 3, 20)
      expect(schedule.to_s).to eq("March 20, 2010")
    end

    it "should work with additional dates" do
      schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
      schedule.add_recurrence_time Time.local(2010, 3, 20)
      schedule.add_recurrence_time Time.local(2010, 3, 21)
      expect(schedule.to_s).to eq("March 20, 2010 / March 21, 2010")
    end

    it "should order dates that are out of order" do
      schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
      schedule.add_recurrence_time Time.local(2010, 3, 19)
      expect(schedule.to_s).to eq("March 19, 2010 / March 20, 2010")
    end

    it "should remove duplicated start time" do
      schedule = IceCube::Schedule.new t0 = Time.local(2010, 3, 20)
      schedule.add_recurrence_time t0
      expect(schedule.to_s).to eq("March 20, 2010")
    end

    it "should remove duplicate rtimes" do
      schedule = IceCube::Schedule.new Time.local(2010, 3, 19)
      schedule.add_recurrence_time Time.local(2010, 3, 20)
      schedule.add_recurrence_time Time.local(2010, 3, 20)
      expect(schedule.to_s).to eq("March 19, 2010 / March 20, 2010")
    end

    it "should work with rules and dates" do
      schedule = IceCube::Schedule.new Time.local(2010, 3, 19)
      schedule.add_recurrence_time Time.local(2010, 3, 20)
      schedule.add_recurrence_rule IceCube::Rule.weekly
      expect(schedule.to_s).to eq("March 20, 2010 / Weekly")
    end

    it "should work with rules and times and exception times" do
      schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
      schedule.add_recurrence_rule IceCube::Rule.weekly
      schedule.add_recurrence_time Time.local(2010, 3, 20)
      schedule.add_exception_time Time.local(2010, 3, 20) # ignored
      schedule.add_exception_time Time.local(2010, 3, 21)
      expect(schedule.to_s).to eq("Weekly / not on March 20, 2010 / not on March 21, 2010")
    end

    it "should work with a single rrule" do
      schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
      schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(monday: [1])
      expect(schedule.to_s).to eq(schedule.rrules[0].to_s)
    end

    it "should be able to say the last Thursday of the month" do
      rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-1]).to_s
      expect(rule_str).to eq("Monthly on the last Thursday")
    end

    it "should be able to say what months of the year something happens" do
      rule_str = IceCube::Rule.yearly.month_of_year(:june, :july).to_s
      expect(rule_str).to eq("Yearly in June and July")
    end

    it "should be able to say the second to last monday of the month" do
      rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-2]).to_s
      expect(rule_str).to eq("Monthly on the 2nd to last Thursday")
    end

    it "should join the first and last weekdays of the month" do
      rule_str = IceCube::Rule.monthly.day_of_week(thursday: [1, -1]).to_s
      expect(rule_str).to eq("Monthly on the 1st Thursday and last Thursday")
    end

    it "should be able to say the days of the month something happens" do
      rule_str = IceCube::Rule.monthly.day_of_month(1, 15, 30).to_s
      expect(rule_str).to eq("Monthly on the 1st, 15th, and 30th days of the month")
    end

    it "should be able to say what day of the year something happens" do
      rule_str = IceCube::Rule.yearly.day_of_year(30).to_s
      expect(rule_str).to eq("Yearly on the 30th day of the year")
    end

    it "should be able to say what hour of the day something happens" do
      rule_str = IceCube::Rule.daily.hour_of_day(6, 12).to_s
      expect(rule_str).to eq("Daily on the 6th and 12th hours of the day")
    end

    it "should be able to say what minute of an hour something happens - with special suffix minutes" do
      rule_str = IceCube::Rule.hourly.minute_of_hour(10, 11, 12, 13, 14, 15).to_s
      expect(rule_str).to eq("Hourly on the 10th, 11th, 12th, 13th, 14th, and 15th minutes of the hour")
    end

    it "should be able to say what seconds of the minute something happens" do
      rule_str = IceCube::Rule.minutely.second_of_minute(10, 11).to_s
      expect(rule_str).to eq("Minutely on the 10th and 11th seconds of the minute")
    end

    it "should be able to reflect until dates" do
      schedule = IceCube::Schedule.new(Time.now)
      schedule.rrule IceCube::Rule.weekly.until(Time.local(2012, 2, 3))
      expect(schedule.to_s).to eq("Weekly until February 3, 2012")
    end

    it "should be able to reflect count" do
      schedule = IceCube::Schedule.new(Time.now)
      schedule.add_recurrence_rule IceCube::Rule.weekly.count(1)
      expect(schedule.to_s).to eq("Weekly 1 time")
    end

    it "should be able to reflect count (proper pluralization)" do
      schedule = IceCube::Schedule.new(Time.now)
      schedule.add_recurrence_rule IceCube::Rule.weekly.count(2)
      expect(schedule.to_s).to eq("Weekly 2 times")
    end
  end

  context "without I18n" do
    before { allow(IceCube::I18n).to receive(:backend) { IceCube::NullI18n } }

    it_behaves_like "to_s in English"
  end

  context "with I18n" do
    before(:each) { I18n.locale = :en }

    it "uses I18n" do
      expect(IceCube::I18n).to eq ::I18n
    end

    it_behaves_like "to_s in English"
  end
end
