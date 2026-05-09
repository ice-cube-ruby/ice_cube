require File.dirname(__FILE__) + "/../spec_helper"

describe IceCube::Schedule, "to_s", locale: "ja" do
  it "should represent its start time by default" do
    t0 = Time.local(2013, 2, 14)
    expect(IceCube::Schedule.new(t0).to_s).to eq("2013年02月14日")
  end

  it "should have a useful base to_s representation for a secondly rule" do
    expect(IceCube::Rule.secondly.to_s).to eq("毎秒")
    expect(IceCube::Rule.secondly(2).to_s).to eq("2秒ごと")
  end

  it "should have a useful base to_s representation for a minutely rule" do
    expect(IceCube::Rule.minutely.to_s).to eq("毎分")
    expect(IceCube::Rule.minutely(2).to_s).to eq("2分ごと")
  end

  it "should have a useful base to_s representation for a hourly rule" do
    expect(IceCube::Rule.hourly.to_s).to eq("毎時間")
    expect(IceCube::Rule.hourly(2).to_s).to eq("2時間ごと")
  end

  it "should have a useful base to_s representation for a daily rule" do
    expect(IceCube::Rule.daily.to_s).to eq("毎日")
    expect(IceCube::Rule.daily(2).to_s).to eq("2日ごと")
  end

  it "should have a useful base to_s representation for a weekly rule" do
    expect(IceCube::Rule.weekly.to_s).to eq("毎週")
    expect(IceCube::Rule.weekly(2).to_s).to eq("2週間ごと")
  end

  it "should have a useful base to_s representation for a monthly rule" do
    expect(IceCube::Rule.monthly.to_s).to eq("毎月")
    expect(IceCube::Rule.monthly(2).to_s).to eq("2ヶ月ごと")
  end

  it "should have a useful base to_s representation for a yearly rule" do
    expect(IceCube::Rule.yearly.to_s).to eq("毎年")
    expect(IceCube::Rule.yearly(2).to_s).to eq("2年ごと")
  end

  it "should work with various sentence types properly" do
    expect(IceCube::Rule.weekly.to_s).to eq("毎週")
    expect(IceCube::Rule.weekly.day(:monday).to_s).to eq("毎週月曜")
    expect(IceCube::Rule.weekly.day(:monday, :tuesday).to_s).to eq("毎週月曜、火曜")
    expect(IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s).to eq("毎週月曜、火曜、水曜")
  end

  it "should show saturday and sunday as weekends" do
    expect(IceCube::Rule.weekly.day(:saturday, :sunday).to_s).to eq("毎週週末")
  end

  it "should not show saturday and sunday as weekends when other days are present also" do
    expect(IceCube::Rule.weekly.day(:sunday, :monday, :saturday).to_s).to eq(
      "毎週日曜、月曜、土曜"
    )
  end

  it "should reorganize days to be in order" do
    expect(IceCube::Rule.weekly.day(:tuesday, :monday).to_s).to eq(
      "毎週月曜、火曜"
    )
  end

  it "should show weekdays as such" do
    expect(IceCube::Rule.weekly.day(
      :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s).to eq("毎週平日")
  end

  it "should not show weekdays as such when a weekend day is present" do
    expect(IceCube::Rule.weekly.day(
      :sunday, :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s).to eq("毎週日曜、月曜、火曜、水曜、木曜、金曜")
  end

  it "should show start time for an empty schedule" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("2010年03月20日")
  end

  it "should work with a single date" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("2010年03月20日")
  end

  it "should work with additional dates" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 21)
    expect(schedule.to_s).to eq("2010年03月20日 / 2010年03月21日")
  end

  it "should order dates that are out of order" do
    schedule = IceCube::Schedule.new(Time.local(2010, 3, 20)) do |s|
      s.add_recurrence_time s.start_time - ONE_DAY
    end
    expect(schedule.to_s).to eq("2010年03月19日 / 2010年03月20日")
  end

  it "should remove duplicated start time" do
    schedule = IceCube::Schedule.new(Time.local(2010, 3, 20)) do |s|
      s.add_recurrence_time s.start_time
    end
    expect(schedule.to_s).to eq("2010年03月20日")
  end

  it "should remove duplicate rtimes" do
    schedule = IceCube::Schedule.new(Time.local(2010, 3, 19)) do |s|
      s.add_recurrence_time s.start_time + ONE_DAY
      s.add_recurrence_time s.start_time + ONE_DAY
    end
    expect(schedule.to_s).to eq("2010年03月19日 / 2010年03月20日")
  end

  it "should work with rules and dates" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 19)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    expect(schedule.to_s).to eq("2010年03月20日 / 毎週")
  end

  it "should work with rules and times and exception times" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_exception_time Time.local(2010, 3, 20) # ignored
    schedule.add_exception_time Time.local(2010, 3, 21)
    expect(schedule.to_s).to eq("毎週 / 2010年03月20日以外 / 2010年03月21日以外")
  end

  it "should work with a single rrule" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(monday: [1])
    expect(schedule.to_s).to eq(schedule.rrules[0].to_s)
  end

  it "should be able to say the last Thursday of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-1]).to_s
    expect(rule_str).to eq("毎月最終木曜")
  end

  it "should be able to say what months of the year something happens" do
    rule_str = IceCube::Rule.yearly.month_of_year(:june, :july).to_s
    expect(rule_str).to eq("毎年6月、7月")
  end

  it "should be able to say the second to last monday of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-2]).to_s
    expect(rule_str).to eq("毎月最後から2番目の木曜")
  end

  it "should join the first and last weekdays of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [1, -1]).to_s
    expect(rule_str).to eq("毎月1木曜、最終木曜")
  end

  it "should be able to say the days of the month something happens" do
    rule_str = IceCube::Rule.monthly.day_of_month(1, 15, 30).to_s
    expect(rule_str).to eq("毎月1、15、30日")
  end

  it "should be able to say what day of the year something happens" do
    rule_str = IceCube::Rule.yearly.day_of_year(30).to_s
    expect(rule_str).to eq("毎年30日")
  end

  it "should be able to say what hour of the day something happens" do
    rule_str = IceCube::Rule.daily.hour_of_day(6, 12).to_s
    expect(rule_str).to eq("毎日6、12時")
  end

  it "should be able to say what minute of an hour something happens - with special suffix minutes" do
    rule_str = IceCube::Rule.hourly.minute_of_hour(10, 11, 12, 13, 14, 15).to_s
    expect(rule_str).to eq("毎時間10、11、12、13、14、15分")
  end

  it "should be able to say what seconds of the minute something happens" do
    rule_str = IceCube::Rule.minutely.second_of_minute(10, 11).to_s
    expect(rule_str).to eq("毎分10、11秒")
  end

  it "should be able to reflect until dates" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.rrule IceCube::Rule.weekly.until(Time.local(2012, 2, 3))
    expect(schedule.to_s).to eq("2012年02月03日まで毎週")
  end

  it "should be able to reflect count" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(1)
    expect(schedule.to_s).to eq("毎週1回")
  end

  it "should be able to reflect count (proper pluralization)" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(2)
    expect(schedule.to_s).to eq("毎週2回")
  end
end
