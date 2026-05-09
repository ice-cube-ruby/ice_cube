require File.dirname(__FILE__) + "/../spec_helper"

describe IceCube::Schedule, "to_s" do
  before :each do
    I18n.locale = :de
  end

  after :all do
    I18n.locale = :en
  end

  it "should represent its start time by default" do
    t0 = Time.local(2013, 2, 14)
    expect(IceCube::Schedule.new(t0).to_s).to eq("14. Februar 2013")
  end

  it "should have a useful base to_s representation for a secondly rule" do
    expect(IceCube::Rule.secondly.to_s).to eq("Jede Sekunde")
    expect(IceCube::Rule.secondly(2).to_s).to eq("Alle 2 Sekunden")
  end

  it "should have a useful base to_s representation for a minutely rule" do
    expect(IceCube::Rule.minutely.to_s).to eq("Jede Minute")
    expect(IceCube::Rule.minutely(2).to_s).to eq("Alle 2 Minuten")
  end

  it "should have a useful base to_s representation for a hourly rule" do
    expect(IceCube::Rule.hourly.to_s).to eq("Stündlich")
    expect(IceCube::Rule.hourly(2).to_s).to eq("Alle 2 Stunden")
  end

  it "should have a useful base to_s representation for a daily rule" do
    expect(IceCube::Rule.daily.to_s).to eq("Täglich")
    expect(IceCube::Rule.daily(2).to_s).to eq("Alle 2 Tage")
  end

  it "should have a useful base to_s representation for a weekly rule" do
    expect(IceCube::Rule.weekly.to_s).to eq("Wöchentlich")
    expect(IceCube::Rule.weekly(2).to_s).to eq("Alle 2 Wochen")
  end

  it "should have a useful base to_s representation for a monthly rule" do
    expect(IceCube::Rule.monthly.to_s).to eq("Monatlich")
    expect(IceCube::Rule.monthly(2).to_s).to eq("Alle 2 Monate")
  end

  it "should have a useful base to_s representation for a yearly rule" do
    expect(IceCube::Rule.yearly.to_s).to eq("Jährlich")
    expect(IceCube::Rule.yearly(2).to_s).to eq("Alle 2 Jahre")
  end

  it "should work with various sentence types properly" do
    expect(IceCube::Rule.weekly.to_s).to eq("Wöchentlich")
    expect(IceCube::Rule.weekly.day(:monday).to_s).to eq("Wöchentlich Montags")
    expect(IceCube::Rule.weekly.day(:monday, :tuesday).to_s).to eq("Wöchentlich Montags und Dienstags")
    expect(IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s).to eq("Wöchentlich Montags, Dienstags und Mittwochs")
  end

  it "should show saturday and sunday as weekends" do
    expect(IceCube::Rule.weekly.day(:saturday, :sunday).to_s).to eq("Wöchentlich am Wochenende")
  end

  it "should not show saturday and sunday as weekends when other days are present also" do
    expect(IceCube::Rule.weekly.day(:sunday, :monday, :saturday).to_s).to eq(
      "Wöchentlich Sonntags, Montags und Samstags"
    )
  end

  it "should reorganize days to be in order" do
    expect(IceCube::Rule.weekly.day(:tuesday, :monday).to_s).to eq(
      "Wöchentlich Montags und Dienstags"
    )
  end

  it "should show weekdays as such" do
    expect(IceCube::Rule.weekly.day(
      :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s).to eq("Wöchentlich an Wochentagen")
  end

  it "should not show weekdays as such when a weekend day is present" do
    expect(IceCube::Rule.weekly.day(
      :sunday, :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s).to eq("Wöchentlich Sonntags, Montags, Dienstags, Mittwochs, Donnerstags und Freitags")
    # 'Weekly on Sundays, Mondays, Tuesdays, Wednesdays, Thursdays, and Fridays'
  end

  it "should show start time for an empty schedule" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("20. März 2010")
  end

  it "should work with a single date" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("20. März 2010")
  end

  it "should work with additional dates" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 21)
    expect(schedule.to_s).to eq("20. März 2010 / 21. März 2010")
  end

  it "should order dates that are out of order" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 19)
    expect(schedule.to_s).to eq("19. März 2010 / 20. März 2010")
  end

  it "should remove duplicated start time" do
    schedule = IceCube::Schedule.new t0 = Time.local(2010, 3, 20)
    schedule.add_recurrence_time t0
    expect(schedule.to_s).to eq("20. März 2010")
  end

  it "should remove duplicate rtimes" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 19)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("19. März 2010 / 20. März 2010")
  end

  it "should work with rules and dates" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 19)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    expect(schedule.to_s).to eq("20. März 2010 / Wöchentlich")
  end

  it "should work with rules and times and exception times" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_exception_time Time.local(2010, 3, 20) # ignored
    schedule.add_exception_time Time.local(2010, 3, 21)
    expect(schedule.to_s).to eq("Wöchentlich / außer am 20. März 2010 / außer am 21. März 2010")
  end

  it "should work with a single rrule" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(monday: [1])
    expect(schedule.to_s).to eq(schedule.rrules[0].to_s)
  end

  it "should be able to say the last Thursday of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-1]).to_s
    expect(rule_str).to eq("Monatlich am letzten Donnerstag")
  end

  it "should be able to say what months of the year something happens" do
    rule_str = IceCube::Rule.yearly.month_of_year(:june, :july).to_s
    expect(rule_str).to eq("Jährlich im Juni und Juli")
  end

  it "should be able to say the second to last monday of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-2]).to_s
    expect(rule_str).to eq("Monatlich am vorletzten Donnerstag")
  end

  it "should join the first and last weekdays of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [1, -1]).to_s
    expect(rule_str).to eq("Monatlich am 1. Donnerstag und letzten Donnerstag")
  end

  it "should be able to say the days of the month something happens" do
    rule_str = IceCube::Rule.monthly.day_of_month(1, 15, 30).to_s
    expect(rule_str).to eq("Monatlich am 1., 15. und 30. Tag des Monats")
  end

  it "should be able to say what day of the year something happens" do
    rule_str = IceCube::Rule.yearly.day_of_year(30).to_s
    expect(rule_str).to eq("Jährlich am 30. Tag des Jahres")
  end

  it "should be able to say what hour of the day something happens" do
    rule_str = IceCube::Rule.daily.hour_of_day(6, 12).to_s
    expect(rule_str).to eq("Täglich in der 6. und 12. Stunde des Tages")
  end

  it "should be able to say what minute of an hour something happens - with special suffix minutes" do
    rule_str = IceCube::Rule.hourly.minute_of_hour(10, 11, 12, 13, 14, 15).to_s
    expect(rule_str).to eq("Stündlich in der 10., 11., 12., 13., 14. und 15. Minute der Stunde")
  end

  it "should be able to say what seconds of the minute something happens" do
    rule_str = IceCube::Rule.minutely.second_of_minute(10, 11).to_s
    expect(rule_str).to eq("Jede Minute in der 10. und 11. Sekunde der Minute")
  end

  it "should be able to reflect until dates" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.rrule IceCube::Rule.weekly.until(Time.local(2012, 2, 3))
    expect(schedule.to_s).to eq("Wöchentlich bis zum 3. Februar 2012")
  end

  it "should be able to reflect count" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(1)
    expect(schedule.to_s).to eq("Wöchentlich 1 mal")
  end

  it "should be able to reflect count (proper pluralization)" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(2)
    expect(schedule.to_s).to eq("Wöchentlich 2 mal")
  end
end
