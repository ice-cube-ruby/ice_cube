# encoding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::Schedule, 'to_s' do
  before :each do
    I18n.locale = :es
  end

  after :all do
    I18n.locale = :en
  end

  it 'should represent its start time by default' do
    t0 = Time.local(2013, 2, 14)
    IceCube::Schedule.new(t0).to_s.should == '14 de Febrero de 2013'
  end

  it 'should have a useful base to_s representation for a secondly rule' do
    IceCube::Rule.secondly.to_s.should == 'Cada segundo'
    IceCube::Rule.secondly(2).to_s.should == 'Cada 2 segundos'
  end

  it 'should have a useful base to_s representation for a minutely rule' do
    IceCube::Rule.minutely.to_s.should == 'Cada minuto'
    IceCube::Rule.minutely(2).to_s.should == 'Cada 2 minutos'
  end

  it 'should have a useful base to_s representation for a hourly rule' do
    IceCube::Rule.hourly.to_s.should == 'Cada hora'
    IceCube::Rule.hourly(2).to_s.should == 'Cada 2 horas'
  end

  it 'should have a useful base to_s representation for a daily rule' do
    IceCube::Rule.daily.to_s.should == 'Diariamente'
    IceCube::Rule.daily(2).to_s.should == 'Cada 2 días'
  end

  it 'should have a useful base to_s representation for a weekly rule' do
    IceCube::Rule.weekly.to_s.should == 'Semanalmente'
    IceCube::Rule.weekly(2).to_s.should == 'Cada 2 semanas'
  end

  it 'should have a useful base to_s representation for a monthly rule' do
    IceCube::Rule.monthly.to_s.should == 'Mensualmente'
    IceCube::Rule.monthly(2).to_s.should == 'Cada 2 meses'
  end

  it 'should have a useful base to_s representation for a yearly rule' do
    IceCube::Rule.yearly.to_s.should == 'Anualmente'
    IceCube::Rule.yearly(2).to_s.should == 'Cada 2 años'
  end

  it 'should work with various sentence types properly' do
    IceCube::Rule.weekly.to_s.should == 'Semanalmente'
    IceCube::Rule.weekly.day(:monday).to_s.should == 'Semanalmente los lunes'
    IceCube::Rule.weekly.day(:monday, :tuesday).to_s.should == 'Semanalmente los lunes y los martes'
    IceCube::Rule.weekly.day(:monday, :tuesday, :wednesday).to_s.should == 'Semanalmente los lunes, los martes y los miércoles'
  end

  it 'should show saturday and sunday as weekends' do
    IceCube::Rule.weekly.day(:saturday, :sunday).to_s.should == 'Semanalmente en fin de semana'
  end

  it 'should not show saturday and sunday as weekends when other days are present also' do
    IceCube::Rule.weekly.day(:sunday, :monday, :saturday).to_s.should ==
      'Semanalmente los domingos, los lunes y los sábados'
  end

  it 'should reorganize days to be in order' do
    IceCube::Rule.weekly.day(:tuesday, :monday).to_s.should ==
      'Semanalmente los lunes y los martes'
  end

  it 'should show weekdays as such' do
    IceCube::Rule.weekly.day(
      :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s.should == 'Semanalmente en días laborables'
  end

  it 'should not show weekdays as such when a weekend day is present' do
    IceCube::Rule.weekly.day(
      :sunday, :monday, :tuesday, :wednesday,
      :thursday, :friday
    ).to_s.should == 'Semanalmente los domingos, los lunes, los martes, los miércoles, los jueves y los viernes'
  end

  it 'should work with a single date' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.to_s.should == "20 de Marzo de 2010"
  end

  it 'should work with additional dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 21)
    schedule.to_s.should == '20 de Marzo de 2010, 21 de Marzo de 2010'
  end

  it 'should order dates that are out of order' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 19)
    schedule.to_s.should == '19 de Marzo de 2010, 20 de Marzo de 2010'
  end

  it 'should remove duplicated start time' do
    schedule = IceCube::Schedule.new t0 = Time.local(2010, 3, 20)
    schedule.add_recurrence_time t0
    schedule.to_s.should == '20 de Marzo de 2010'
  end

  it 'should remove duplicate rtimes' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.to_s.should == '20 de Marzo de 2010'
  end

  it 'should work with rules and dates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.to_s.should == '20 de Marzo de 2010, Semanalmente'
  end

  it 'should work with rules and dates and exdates' do
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly
    schedule.add_recurrence_time Time.local(2010, 3, 20)
    schedule.add_exception_date Time.local(2010, 3, 20) # ignored
    schedule.add_exception_date Time.local(2010, 3, 21)
    # TODO: this text should be improved to add sentence connector
    schedule.to_s.should == 'Semanalmente, excepto el 20 de Marzo de 2010, excepto el 21 de Marzo de 2010'
  end

  it 'should work with a single rrule' do
    pending 'remove dependency'
    schedule = IceCube::Schedule.new Time.local(2010, 3, 20)
    schedule.add_recurrence_rule IceCube::Rule.weekly.day_of_week(:monday => [1])
    schedule.to_s.should == schedule.rrules[0].to_s
  end

  it 'should be able to say the last monday of the month' do
    rule_str = IceCube::Rule.monthly.day_of_week(:thursday => [-1]).to_s
    rule_str.should == 'Mensualmente en el último Jueves'
  end

  it 'should be able to say what months of the year something happens' do
    rule_str = IceCube::Rule.yearly.month_of_year(:june, :july).to_s
    rule_str.should == 'Anualmente en Junio y Julio'
  end

  it 'should be able to say the second to last monday of the month' do
    pending 'penultimo'
    rule_str = IceCube::Rule.monthly.day_of_week(:thursday => [-2]).to_s
    rule_str.should == 'Mensualmente del segundo al último Jueves del mes'
  end

  it 'should be able to say the days of the month something happens' do
    rule_str = IceCube::Rule.monthly.day_of_month(1, 15, 30).to_s
    rule_str.should == 'Mensualmente en los días 1º, 15º y 30º del mes'
  end

  it 'should be able to say what day of the year something happens' do
    rule_str = IceCube::Rule.yearly.day_of_year(30).to_s
    rule_str.should == 'Anualmente en el día 30º'
  end

  it 'should be able to say what hour of the day something happens' do
    rule_str = IceCube::Rule.daily.hour_of_day(6, 12).to_s
    rule_str.should == 'Diariamente en las horas 6º y 12º'
  end

  it 'should be able to say what minute of an hour something happens - with special suffix minutes' do
    rule_str = IceCube::Rule.hourly.minute_of_hour(10, 11, 12, 13, 14, 15).to_s
    rule_str.should == 'Cada hora en los minutos 10º, 11º, 12º, 13º, 14º y 15º'
  end

  it 'should be able to say what seconds of the minute something happens' do
    rule_str = IceCube::Rule.minutely.second_of_minute(10, 11).to_s
    rule_str.should == 'Cada minuto en los segundos 10º y 11º del minuto'
  end

  it 'should be able to reflect until dates' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.rrule IceCube::Rule.weekly.until(Time.local(2012, 2, 3))
    schedule.to_s.should == 'Semanalmente hasta el 3 de Febrero de 2012'
  end

  it 'should be able to reflect count' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(1)
    schedule.to_s.should == 'Semanalmente 1 vez'
  end

  it 'should be able to reflect count (proper pluralization)' do
    schedule = IceCube::Schedule.new(Time.now)
    schedule.add_recurrence_rule IceCube::Rule.weekly.count(2)
    schedule.to_s.should == 'Semanalmente 2 veces'
  end

  # it 'should work when an end_time is set' do
  #   schedule = IceCube::Schedule.new(Time.local(2012, 8, 31), :end_time => Time.local(2012, 10, 31))
  #   schedule.add_recurrence_rule IceCube::Rule.daily.count(2)
  #   schedule.to_s.should == 'Diariamente 2 veces, hasta el 31 de Octubre 2012'
  # end

end
