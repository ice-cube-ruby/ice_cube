require File.dirname(__FILE__) + "/../spec_helper"

describe IceCube::Schedule, "to_s" do
  before :each do
    I18n.locale = :id
  end

  after :all do
    I18n.locale = :en
  end

  it "should represent its start time by default" do
    t0 = Time.local(2013, 2, 14)
    expect(IceCube::Schedule.new(t0).to_s).to eq("14 Februari 2013")
  end

  it "should have a useful base to_s representation for a secondly rule" do
    expect(IceCube::Rule.secondly.to_s).to eq("Setiap detik")
    expect(IceCube::Rule.secondly(2).to_s).to eq("Setiap 2 detik")
  end

  it "should have a useful base to_s representation for a minutely rule" do
    expect(IceCube::Rule.minutely.to_s).to eq("Setiap menit")
    expect(IceCube::Rule.minutely(2).to_s).to eq("Setiap 2 menit")
  end

  it "should have a useful base to_s representation for a hourly rule" do
    expect(IceCube::Rule.hourly.to_s).to eq("Setiap jam")
    expect(IceCube::Rule.hourly(2).to_s).to eq("Setiap 2 jam")
  end

  it "should have a useful base to_s representation for a daily rule" do
    expect(IceCube::Rule.daily.to_s).to eq("Setiap hari")
    expect(IceCube::Rule.daily(2).to_s).to eq("Setiap 2 hari")
  end

  it "should have a useful base to_s representation for a weekly rule" do
    expect(IceCube::Rule.weekly.to_s).to eq("Setiap minggu")
    expect(IceCube::Rule.weekly(2).to_s).to eq("Setiap 2 minggu")
  end

  it "should have a useful base to_s representation for a monthly rule" do
    expect(IceCube::Rule.monthly.to_s).to eq("Setiap bulan")
    expect(IceCube::Rule.monthly(2).to_s).to eq("Setiap 2 bulan")
  end

  it "should have a useful base to_s representation for a yearly rule" do
    expect(IceCube::Rule.yearly.to_s).to eq("Setiap tahun")
    expect(IceCube::Rule.yearly(2).to_s).to eq("Setiap 2 tahun")
  end

  it "should work with various sentence types properly" do
    expect(IceCube::Rule.weekly.to_s).to eq("Setiap minggu")
    expect(IceCube::Rule.weekly.day(:monday).to_s).to eq("Setiap minggu pada Hari senin")
    expect(IceCube::Rule.weekly.day(:monday, :tuesday).to_s).to eq("Setiap minggu pada Hari senin dan Hari selasa")
    expect(IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s).to eq("Setiap minggu pada Hari senin, Hari selasa dan Hari rabu")
  end

  it "should show saturday and sunday as weekends" do
    expect(IceCube::Rule.weekly.day(:saturday, :sunday).to_s).to eq("Setiap minggu pada akhir pekan")
  end

  it "should not show saturday and sunday as weekends when other days are present also" do
    expect(IceCube::Rule.weekly.day(:sunday, :monday, :saturday).to_s).to eq(
      "Setiap minggu pada Hari minggu, Hari senin dan Hari sabtu"
    )
  end

  it "should reorganize days to be in order" do
    expect(IceCube::Rule.weekly.day(:tuesday, :monday).to_s).to eq(
      "Setiap minggu pada Hari senin dan Hari selasa"
    )
  end

  it "should show weekdays as such" do
    expect(IceCube::Rule.weekly.day(
      :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s).to eq("Setiap minggu pada hari kerja")
  end

  it "should not show weekdays as such when a weekend day is present" do
    expect(IceCube::Rule.weekly.day(
      :sunday, :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s).to eq("Setiap minggu pada Hari minggu, Hari senin, Hari selasa, Hari rabu, Hari kamis dan Hari jumat")
  end

  it "should show start time for an empty schedule" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("20 Maret 2010")
  end

  it "should work with a single date" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("20 Maret 2010")
  end

  it "should work with additional dates" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 21)
    expect(schedule.to_s).to eq("20 Maret 2010 / 21 Maret 2010")
  end

  it "should order dates that are out of order" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 19)
    expect(schedule.to_s).to eq("19 Maret 2010 / 20 Maret 2010")
  end

  it "should remove duplicated start time" do
    schedule = IceCube::Schedule.new t0 = Time.local(2010, 3, 20)
    schedule.add_recurrence_time t0
    expect(schedule.to_s).to eq("20 Maret 2010")
  end

  it "should remove duplicate rtimes" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 19)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("19 Maret 2010 / 20 Maret 2010")
  end

  it "should work with rules and dates" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 19)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    expect(schedule.to_s).to eq("20 Maret 2010 / Setiap minggu")
  end

  it "should work with rules and times and exception times" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_exception_time Time.local(2010, 3, 20) # ignored
    schedule.add_exception_time Time.local(2010, 3, 21)
    expect(schedule.to_s).to eq("Setiap minggu / kecuali 20 Maret 2010 / kecuali 21 Maret 2010")
  end

  it "should work with a single rule" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(monday: [1])
    expect(schedule.to_s).to eq(schedule.rrules[0].to_s)
  end

  it "should be able to say the last Thursday of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-1]).to_s
    expect(rule_str).to eq("Setiap bulan pada terakhir Kamis")
  end

  it "should be able to say what months of the year something happens" do
    rule_str = IceCube::Rule.yearly.month_of_year(:june, :july).to_s
    expect(rule_str).to eq("Setiap tahun pada Juni dan Juli")
  end

  it "should be able to say the second to last monday of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-2]).to_s
    expect(rule_str).to eq("Setiap bulan pada kedua sampai terakhir Kamis")
  end

  it "should join the first and last weekdays of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [1, -1]).to_s
    expect(rule_str).to eq("Setiap bulan pada pertama Kamis dan terakhir Kamis")
  end

  it "should be able to say the days of the month something happens" do
    rule_str = IceCube::Rule.monthly.day_of_month(1, 15, 30).to_s
    expect(rule_str).to eq("Setiap bulan pada hari ke pertama, 15 dan 30 dalam satu bulan")
  end

  it "should be able to say what day of the year something happens" do
    rule_str = IceCube::Rule.yearly.day_of_year(30).to_s
    expect(rule_str).to eq("Setiap tahun pada hari ke 30 dalam satu tahun")
  end

  it "should be able to say what hour of the day something happens" do
    rule_str = IceCube::Rule.daily.hour_of_day(6, 12).to_s
    expect(rule_str).to eq("Setiap hari pada jam 6 dan 12 dalam satu hari")
  end

  it "should be able to say what minute of an hour something happens - with special suffix minutes" do
    rule_str = IceCube::Rule.hourly.minute_of_hour(10, 11, 12, 13, 14, 15).to_s
    expect(rule_str).to eq("Setiap jam pada menit ke 10, 11, 12, 13, 14 dan 15 dalam satu jam")
  end

  it "should be able to say what seconds of the minute something happens" do
    rule_str = IceCube::Rule.minutely.second_of_minute(10, 11).to_s
    expect(rule_str).to eq("Setiap menit pada detik ke 10 dan 11 dalam satu menit")
  end

  it "should be able to reflect until dates" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.rrule IceCube::Rule.weekly.until(Time.local(2012, 2, 3))
    expect(schedule.to_s).to eq("Setiap minggu sampai  3 Februari 2012")
  end

  it "should be able to reflect count" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(1)
    expect(schedule.to_s).to eq("Setiap minggu 1 kali")
  end

  it "should be able to reflect count (proper pluralization)" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(2)
    expect(schedule.to_s).to eq("Setiap minggu 2 kali")
  end
end
