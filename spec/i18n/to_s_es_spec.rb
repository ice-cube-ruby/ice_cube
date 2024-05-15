require File.dirname(__FILE__) + "/../spec_helper"

describe IceCube::Schedule, "to_s" do
  before :each do
    I18n.locale = :es
  end

  after :all do
    I18n.locale = :en
  end

  it "should represent its start time by default" do
    t0 = Time.local(2013, 2, 14)
    expect(IceCube::Schedule.new(t0).to_s).to eq("14 de Febrero de 2013")
  end

  it "should have a useful base to_s representation for a secondly rule" do
    expect(IceCube::Rule.secondly.to_s).to eq("Cada segundo")
    expect(IceCube::Rule.secondly(2).to_s).to eq("Cada 2 segundos")
  end

  it "should have a useful base to_s representation for a minutely rule" do
    expect(IceCube::Rule.minutely.to_s).to eq("Cada minuto")
    expect(IceCube::Rule.minutely(2).to_s).to eq("Cada 2 minutos")
  end

  it "should have a useful base to_s representation for a hourly rule" do
    expect(IceCube::Rule.hourly.to_s).to eq("Cada hora")
    expect(IceCube::Rule.hourly(2).to_s).to eq("Cada 2 horas")
  end

  it "should have a useful base to_s representation for a daily rule" do
    expect(IceCube::Rule.daily.to_s).to eq("Diariamente")
    expect(IceCube::Rule.daily(2).to_s).to eq("Cada 2 días")
  end

  it "should have a useful base to_s representation for a weekly rule" do
    expect(IceCube::Rule.weekly.to_s).to eq("Semanalmente")
    expect(IceCube::Rule.weekly(2).to_s).to eq("Cada 2 semanas")
  end

  it "should have a useful base to_s representation for a monthly rule" do
    expect(IceCube::Rule.monthly.to_s).to eq("Mensualmente")
    expect(IceCube::Rule.monthly(2).to_s).to eq("Cada 2 meses")
  end

  it "should have a useful base to_s representation for a yearly rule" do
    expect(IceCube::Rule.yearly.to_s).to eq("Anualmente")
    expect(IceCube::Rule.yearly(2).to_s).to eq("Cada 2 años")
  end

  it "should work with various sentence types properly" do
    expect(IceCube::Rule.weekly.to_s).to eq("Semanalmente")
    expect(IceCube::Rule.weekly.day(:monday).to_s).to eq("Semanalmente los lunes")
    expect(IceCube::Rule.weekly.day(:monday, :tuesday).to_s).to eq("Semanalmente los lunes y los martes")
    expect(IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s).to eq("Semanalmente los lunes, los martes y los miércoles")
  end

  it "should show saturday and sunday as weekends" do
    expect(IceCube::Rule.weekly.day(:saturday, :sunday).to_s).to eq("Semanalmente en fin de semana")
  end

  it "should not show saturday and sunday as weekends when other days are present also" do
    expect(IceCube::Rule.weekly.day(:sunday, :monday, :saturday).to_s).to eq(
      "Semanalmente los domingos, los lunes y los sábados"
    )
  end

  it "should reorganize days to be in order" do
    expect(IceCube::Rule.weekly.day(:tuesday, :monday).to_s).to eq(
      "Semanalmente los lunes y los martes"
    )
  end

  it "should show weekdays as such" do
    expect(IceCube::Rule.weekly.day(
      :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s).to eq("Semanalmente en días laborables")
  end

  it "should not show weekdays as such when a weekend day is present" do
    expect(IceCube::Rule.weekly.day(
      :sunday, :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s).to eq("Semanalmente los domingos, los lunes, los martes, los miércoles, los jueves y los viernes")
  end

  it "should work with a single date" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("20 de Marzo de 2010")
  end

  it "should work with additional dates" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 21)
    expect(schedule.to_s).to eq("20 de Marzo de 2010, 21 de Marzo de 2010")
  end

  it "should order dates that are out of order" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 19)
    expect(schedule.to_s).to eq("19 de Marzo de 2010, 20 de Marzo de 2010")
  end

  it "should remove duplicated start time" do
    schedule = IceCube::Schedule.new t0 = Time.local(2010, 3, 20)
    schedule.add_recurrence_time t0
    expect(schedule.to_s).to eq("20 de Marzo de 2010")
  end

  it "should remove duplicate rtimes" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    expect(schedule.to_s).to eq("20 de Marzo de 2010")
  end

  it "should work with rules and dates" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    expect(schedule.to_s).to eq("20 de Marzo de 2010, Semanalmente")
  end

  it "should work with rules and dates and exdates" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_exception_time Time.local(2010, 3, 20) # ignored
    schedule.add_exception_time Time.local(2010, 3, 21)
    # TODO: this text should be improved to add sentence connector
    expect(schedule.to_s).to eq("Semanalmente, excepto el 20 de Marzo de 2010, excepto el 21 de Marzo de 2010")
  end

  it "should work with a single rrule" do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(monday: [1])
    expect(schedule.to_s).to eq(schedule.rrules[0].to_s)
  end

  it "should be able to say the last monday of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-1]).to_s
    expect(rule_str).to eq("Mensualmente en el último Jueves")
  end

  it "should be able to say what months of the year something happens" do
    rule_str = IceCube::Rule.yearly.month_of_year(:june, :july).to_s
    expect(rule_str).to eq("Anualmente en Junio y Julio")
  end

  it "should be able to say the second to last monday of the month" do
    rule_str = IceCube::Rule.monthly.day_of_week(thursday: [-2]).to_s
    expect(rule_str).to eq("Mensualmente en el penúltimo Jueves")
  end

  it "should be able to say the days of the month something happens" do
    rule_str = IceCube::Rule.monthly.day_of_month(1, 15, 30).to_s
    expect(rule_str).to eq("Mensualmente en los días 1º, 15º y 30º del mes")
  end

  it "should be able to say what day of the year something happens" do
    rule_str = IceCube::Rule.yearly.day_of_year(30).to_s
    expect(rule_str).to eq("Anualmente en el día 30º")
  end

  it "should be able to say what hour of the day something happens" do
    rule_str = IceCube::Rule.daily.hour_of_day(6, 12).to_s
    expect(rule_str).to eq("Diariamente en las horas 6º y 12º")
  end

  it "should be able to say what minute of an hour something happens - with special suffix minutes" do
    rule_str = IceCube::Rule.hourly.minute_of_hour(10, 11, 12, 13, 14, 15).to_s
    expect(rule_str).to eq("Cada hora en los minutos 10º, 11º, 12º, 13º, 14º y 15º")
  end

  it "should be able to say what seconds of the minute something happens" do
    rule_str = IceCube::Rule.minutely.second_of_minute(10, 11).to_s
    expect(rule_str).to eq("Cada minuto en los segundos 10º y 11º del minuto")
  end

  it "should be able to reflect until dates" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.rrule IceCube::Rule.weekly.until(Time.local(2012, 2, 3))
    expect(schedule.to_s).to eq("Semanalmente hasta el 3 de Febrero de 2012")
  end

  it "should be able to reflect count" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(1)
    expect(schedule.to_s).to eq("Semanalmente 1 vez")
  end

  it "should be able to reflect count (proper pluralization)" do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(2)
    expect(schedule.to_s).to eq("Semanalmente 2 veces")
  end

  # it 'should work when an end_time is set' do
  #   schedule = IceCube::Schedule.new(Time.local(2012, 8, 31), :end_time => Time.local(2012, 10, 31))
  #   schedule.add_recurrence_rule IceCube::Rule.daily.count(2)
  #   schedule.to_s.should == 'Diariamente 2 veces, hasta el 31 de Octubre 2012'
  # end
end
