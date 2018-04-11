require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe Schedule do

    # DST in 2010 is March 14th at 2am
    it 'crosses a daylight savings time boundary with a recurrence rule in local time, by utc conversion' do
      start_time = Time.local(2010, 3, 13, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily.count(20)
      dates = schedule.first(20)
      expect(dates.size).to eq(20)
      # check assumptions
      dates.each do |date|
        expect(date.utc?).not_to eq(true)
        expect(date.hour).to eq(5)
      end
    end

    # DST in 2010 is November 7th at 2am
    it 'crosses a daylight savings time boundary (in the other direction) with a recurrence rule in local time, by utc conversion' do
      start_time = Time.local(2010, 11, 6, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily.count(20)
      dates = schedule.first(20)
      expect(dates.size).to eq(20)
      # check assumptions
      dates.each do |date|
        expect(date.utc?).not_to eq(true)
        expect(date.hour).to eq(5)
      end
    end

    it 'cross a daylight savings time boundary with a recurrence rule in local time' do
      start_time = Time.local(2010, 3, 14, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily
      # each occurrence MUST occur at 5pm, then we win
      dates = schedule.occurrences(start_time + 20 * ONE_DAY)
      dates.each do |date|
        expect(date.hour).to eq(5)
      end
    end

    it 'every two hours over a daylight savings time boundary, checking interval' do
      start_time = Time.local(2010, 11, 6, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.hourly(2)
      dates = schedule.first(100)
      # check assumption
      distance_in_hours = 0
      dates.each do |d|
        expect(d).to eq(start_time + ONE_HOUR * distance_in_hours)
        distance_in_hours += 2
      end
    end

    it 'every 30 minutes over a daylight savings time boundary, checking interval' do
      start_time = Time.local(2010, 11, 6, 23, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.minutely(30)
      dates = schedule.first(100)
      # check assumption
      distance_in_minutes = 0
      dates.each do |d|
        expect(d).to eq(start_time + ONE_MINUTE * distance_in_minutes)
        distance_in_minutes += 30
      end
    end

    it 'every 120 seconds over a daylight savings time boundary, checking interval' do
      start_time = Time.local(2010, 11, 6, 23, 50, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.secondly(120)
      dates = schedule.first(10)
      # check assumption
      distance_in_seconds = 0
      dates.each do |d|
        expect(d).to eq(start_time + distance_in_seconds)
        distance_in_seconds += 120
      end
    end

    it 'every other day over a daylight savings time boundary, checking hour/min/sec' do
      start_time = Time.local(2010, 11, 6, 20, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily(2)
      dates = schedule.first(10)
      # check assumption
      dates.each do |d|
        expect(d.hour).to eq(start_time.hour)
        expect(d.min).to eq(start_time.min)
        expect(d.sec).to eq(start_time.sec)
      end
    end

    it 'every other month over a daylight savings time boundary, checking day/hour/min/sec' do
      start_time = Time.local(2010, 11, 6, 20, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.monthly(2)
      dates = schedule.first(10)
      # check assumption
      dates.each do |d|
        expect(d.day).to eq(start_time.day)
        expect(d.hour).to eq(start_time.hour)
        expect(d.min).to eq(start_time.min)
        expect(d.sec).to eq(start_time.sec)
      end
    end

    it 'every other year over a daylight savings time boundary, checking day/hour/min/sec' do
      start_time = Time.local(2010, 11, 6, 20, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.yearly(2)
      dates = schedule.first(10)
      # check assumption
      dates.each do |d|
        expect(d.month).to eq(start_time.month)
        expect(d.day).to eq(start_time.day)
        expect(d.hour).to eq(start_time.hour)
        expect(d.min).to eq(start_time.min)
        expect(d.sec).to eq(start_time.sec)
      end
    end

    it 'LOCAL - has an until date on a rule that is over a DST from the start date' do
      start_time = Time.local(2010, 3, 13, 5, 0, 0)
      end_date = Time.local(2010, 3, 15, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily.until(end_date)
      # make sure we end on the proper time
      expect(schedule.all_occurrences.last).to eq(end_date)
    end

    it 'UTC - has an until date on a rule that is over a DST from the start date' do
      start_time = Time.utc(2010, 3, 13, 5, 0, 0)
      end_date = Time.utc(2010, 3, 15, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily.until(end_date)
      # make sure we end on the proper time
      expect(schedule.all_occurrences.last).to eq(end_date)
    end

    it 'LOCAL - has an until date on a rule that is over a DST from the start date (other direction)' do
      start_time = Time.local(2010, 11, 5, 5, 0, 0)
      end_date = Time.local(2010, 11, 10, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily.until(end_date)
      # make sure we end on the proper time
      expect(schedule.all_occurrences.last).to eq(end_date)
    end

    it 'UTC - has an until date on a rule that is over a DST from the start date (other direction)' do
      start_time = Time.utc(2010, 11, 5, 5, 0, 0)
      end_date = Time.utc(2010, 11, 10, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily.until(end_date)
      # make sure we end on the proper time
      expect(schedule.all_occurrences.last).to eq(end_date)
    end

    it 'LOCAL - has an end date on a rule that is over a DST from the start date' do
      start_time = Time.local(2010, 3, 13, 5, 0, 0)
      end_date = Time.local(2010, 3, 15, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily
      # make sure we end on the proper time
      expect(schedule.occurrences(end_date).last).to eq(end_date)
    end

    it 'UTC - has an end date on a rule that is over a DST from the start date' do
      start_time = Time.utc(2010, 3, 13, 5, 0, 0)
      end_date = Time.utc(2010, 3, 15, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily
      # make sure we end on the proper time
      expect(schedule.occurrences(end_date).last).to eq(end_date)
    end

    it 'LOCAL - has an end date on a rule that is over a DST from the start date (other direction)' do
      start_time = Time.local(2010, 11, 5, 5, 0, 0)
      end_date = Time.local(2010, 11, 10, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily
      # make sure we end on the proper time
      expect(schedule.occurrences(end_date).last).to eq(end_date)
    end

    it 'UTC - has an end date on a rule that is over a DST from the start date (other direction)' do
      start_time = Time.utc(2010, 11, 5, 5, 0, 0)
      end_date = Time.utc(2010, 11, 10, 5, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily
      # make sure we end on the proper time
      expect(schedule.occurrences(end_date).last).to eq(end_date)
    end

    it 'local - should make dates on interval over dst - github issue 4' do
      start_time = Time.local(2010, 3, 12, 19, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.daily(3)
      expect(schedule.first(3)).to eq([Time.local(2010, 3, 12, 19, 0, 0), Time.local(2010, 3, 15, 19, 0, 0), Time.local(2010, 3, 18, 19, 0, 0)])
    end

    it 'local - should make dates on monthly interval over dst - github issue 4' do
      start_time = Time.local(2010, 3, 12, 19, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.monthly(2)
      expect(schedule.first(6)).to eq([Time.local(2010, 3, 12, 19, 0, 0), Time.local(2010, 5, 12, 19, 0, 0), Time.local(2010, 7, 12, 19, 0, 0),
                                       Time.local(2010, 9, 12, 19, 0, 0), Time.local(2010, 11, 12, 19, 0, 0), Time.local(2011, 1, 12, 19, 0, 0)])
    end

    it 'local - should make dates on monthly interval over dst - github issue 4' do
      start_time = Time.local(2010, 3, 12, 19, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.monthly
      expect(schedule.first(10)).to eq([Time.local(2010, 3, 12, 19, 0, 0), Time.local(2010, 4, 12, 19, 0, 0), Time.local(2010, 5, 12, 19, 0, 0),
                                        Time.local(2010, 6, 12, 19, 0, 0), Time.local(2010, 7, 12, 19, 0, 0), Time.local(2010, 8, 12, 19, 0, 0),
                                        Time.local(2010, 9, 12, 19, 0, 0), Time.local(2010, 10, 12, 19, 0, 0), Time.local(2010, 11, 12, 19, 0, 0),
                                        Time.local(2010, 12, 12, 19, 0, 0)])
    end

    it 'local - should make dates on yearly interval over dst - github issue 4' do
      start_time = Time.local(2010, 3, 12, 19, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.yearly(2)
      expect(schedule.first(3)).to eq([Time.local(2010, 3, 12, 19, 0, 0), Time.local(2012, 3, 12, 19, 0, 0), Time.local(2014, 3, 12, 19, 0, 0)])
    end

    it "local - should make dates on monthly (day of week) inverval over dst - github issue 5" do
      start_time = Time.local(2010, 3, 7, 12, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.monthly.day_of_week(:sunday => [1])
      expect(schedule.first(3)).to eq([Time.local(2010, 3, 7, 12, 0, 0), Time.local(2010, 4, 4, 12, 0, 0), Time.local(2010, 5, 2, 12, 0, 0)])
    end

    it "local - should make dates on monthly (day of month) inverval over dst - github issue 5" do
      start_time = Time.local(2010, 3, 1, 12, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.monthly.day_of_month(1)
      expect(schedule.first(3)).to eq([Time.local(2010, 3, 1, 12, 0, 0), Time.local(2010, 4, 1, 12, 0, 0), Time.local(2010, 5, 1, 12, 0, 0)])
    end

    it "local - should make dates on weekly (day) inverval over dst - github issue 5" do
      start_time = Time.local(2010, 3, 7, 12, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.weekly.day(:sunday)
      expect(schedule.first(3)).to eq([Time.local(2010, 3, 7, 12, 0, 0), Time.local(2010, 3, 14, 12, 0, 0), Time.local(2010, 3, 21, 12, 0, 0)])
    end

    it "local - should make dates on yearly (day of year) inverval over dst - github issue 5" do
      start_time = Time.local(2010, 3, 7, 12, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.yearly.day_of_year(1)
      expect(schedule.first(4)).to eq([
        start_time,
        Time.local(2011, 1, 1, 12, 0, 0),
        Time.local(2012, 1, 1, 12, 0, 0),
        Time.local(2013, 1, 1, 12, 0, 0),
      ])
    end

    it "local - should make dates on monthly (month_of_year) inverval over dst - github issue 5" do
      start_time = Time.local(2010, 3, 7, 12, 0, 0)
      schedule = Schedule.new(start_time)
      schedule.add_recurrence_rule Rule.yearly.month_of_year(:april).day_of_month(10)
      expect(schedule.first(4)).to eq([
        start_time,
        Time.local(2010, 4, 10, 12, 0, 0),
        Time.local(2011, 4, 10, 12, 0, 0),
        Time.local(2012, 4, 10, 12, 0, 0),
      ])
    end

    it "skips double daily occurrences from end of DST", :system_time_zone => "America/Denver" do
      t0 = Time.local(2013, 11, 3, 1, 30, 0)
      schedule = Schedule.new(t0) { |s| s.rrule Rule.daily.count(3) }
      expect(schedule.all_occurrences).to eq([t0, Time.local(2013, 11, 4, 1, 30, 0), Time.local(2013, 11, 5, 1, 30, 0)])
    end

    it "skips double monthly occurrences from end of DST", :system_time_zone => "America/Nome" do
      t0 = Time.local(2017, 10, 5, 1, 0, 0)
      schedule = Schedule.new(t0) { |s| s.rrule Rule.monthly.day_of_month(5).count(3) }
      expect(schedule.all_occurrences).to eq([t0, t0 + 31*ONE_DAY + ONE_HOUR, t0 + 61*ONE_DAY + ONE_HOUR])
    end

    it "does not skip hourly rules over DST", :system_time_zone => "America/Denver" do
      t0 = Time.local(2013, 11, 3, 1, 30, 0)
      schedule = Schedule.new(t0) { |s| s.rrule Rule.hourly.count(3) }
      expect(schedule.all_occurrences).to eq([t0, t0 + ONE_HOUR, t0 + 2*ONE_HOUR])
    end

    it "does not skip minutely rules with minute of hour over DST", :system_time_zone => "America/Denver" do
      t0 = Time.local(2013, 11, 3, 1, 30, 0)
      schedule = Schedule.new(t0) { |s| s.rrule Rule.hourly.count(3) }
      schedule.rrule Rule.minutely.minute_of_hour([0, 15, 30, 45])
      expect(schedule.first(5)).to eq([t0, t0 + 15*60, t0 + 30*60, t0 + 45*60, t0 + 60*60])
    end

    it "does not skip minutely rules with second of minute over DST", :system_time_zone => "America/Denver" do
      t0 = Time.local(2013, 11, 3, 1, 30, 0)
      schedule = Schedule.new(t0) { |s| s.rrule Rule.hourly.count(3) }
      schedule.rrule Rule.minutely(15).second_of_minute(0)
      expect(schedule.first(5)).to eq([t0, t0 + 15*60, t0 + 30*60, t0 + 45*60, t0 + 60*60])
    end
  end
end
