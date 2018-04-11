require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe Schedule do

    WORLD_TIME_ZONES.each do |zone|
      context "in #{zone}", :system_time_zone => zone do

        it 'should produce the correct result for every day in may [#31]' do
          schedule = Schedule.new { |s| s.add_recurrence_rule Rule.daily.month_of_year(:may) }
          schedule.first(31).all? { |d| d.year == schedule.start_time.year }
        end

        it 'should consider recurrence times properly in find_occurreces [#43]' do
          schedule = Schedule.new(Time.local(2011, 10, 1, 18, 25))
          schedule.add_recurrence_time Time.local(2011, 12, 3, 15, 0, 0)
          schedule.add_recurrence_time Time.local(2011, 12, 3, 10, 0, 0)
          schedule.add_recurrence_time Time.local(2011, 12, 4, 10, 0, 0)
          expect(schedule.occurs_at?(Time.local(2011, 12, 3, 15, 0, 0))).to be_truthy
        end

        it 'should work well with occurrences_between [#33]' do
          schedule = Schedule.new(Time.local(2011, 10, 11, 12))
          schedule.add_recurrence_rule Rule.weekly.day(1).hour_of_day(12).minute_of_hour(0)
          schedule.add_recurrence_rule Rule.weekly.day(2).hour_of_day(15).minute_of_hour(0)
          schedule.add_exception_time Time.local(2011, 10, 13, 21)
          schedule.add_exception_time Time.local(2011, 10, 18, 21)
          expect(schedule.occurrences_between(Time.local(2012, 1, 1), Time.local(2012, 12, 1))).to be_an Array
        end

        it 'should work with all validation locks [#45]' do
          schedule = Schedule.new
          schedule.rrule Rule.monthly.
                             month_of_year(10).day_of_month(13).day(5).
                             hour_of_day(14).minute_of_hour(0).second_of_minute(0)
          expect(schedule.occurrences(Date.today >> 12)).to be_an Array
        end

        it 'should not choke on parsing [#26]' do
          schedule = Schedule.new(Time.local(2011, 8, 9, 14, 52, 14))
          schedule.rrule Rule.weekly(1).day(1, 2, 3, 4, 5)
          expect { Schedule.from_yaml(schedule.to_yaml) }.to_not raise_error
        end

        it 'should parse an old schedule properly', expect_warnings: true do
          file = File.read(File.dirname(__FILE__) + '/../data/issue40.yml')
          schedule = Schedule.from_yaml(file)
          expect(schedule.start_time.year).to eq(2011)
          expect(schedule.start_time.month).to eq(11)
          expect(schedule.start_time.day).to eq(16)
          expect(schedule.start_time.utc_offset).to eq(-5 * 3600)

          expect(schedule.duration).to eq(3600)
          expect(schedule.rrules).to eq([
            Rule.minutely(60).day(4).hour_of_day(14, 15, 16).minute_of_hour(0)
          ])
        end

        it 'should handle a simple weekly schedule [#52]' do
          t0 = Time.new(2011, 12, 1, 18, 0, 0)
          t1 = Time.new(2012, 1, 1, 18, 0, 0)
          schedule = Schedule.new(t0)
          schedule.add_recurrence_rule Rule.weekly(1).day(4).until(t1)
          expect(schedule.all_occurrences).to eq([
            Time.new(2011, 12,  1, 18),
            Time.new(2011, 12,  8, 18),
            Time.new(2011, 12, 15, 18),
            Time.new(2011, 12, 22, 18),
            Time.new(2011, 12, 29, 18)
          ])
        end

        it 'should produce all occurrences between dates, not breaking on exceptions [#82]' do
          schedule = Schedule.new(Time.new(2012, 5, 1))
          schedule.add_recurrence_rule Rule.daily.day(:sunday, :tuesday, :wednesday, :thursday, :friday, :saturday)
          times = schedule.occurrences_between(Time.new(2012, 5, 19), Time.new(2012, 5, 24))
          expect(times).to eq([
            Time.new(2012, 5, 19),
            Time.new(2012, 5, 20),
            # No 21st
            Time.new(2012, 5, 22),
            Time.new(2012, 5, 23),
            Time.new(2012, 5, 24)
          ])
        end

        it 'should be able to use count with occurrences_between falling over counts last occurrence [#54]' do
          schedule = Schedule.new(t0 = Time.now)
          schedule.add_recurrence_rule Rule.daily.count(5)
          expect(schedule.occurrences_between(t0, t0 + ONE_WEEK).count).to eq(5)
          expect(schedule.occurrences_between(t0 + ONE_WEEK, t0 + 2 * ONE_WEEK).count).to eq(0)
        end

        it 'should produce occurrences regardless of time being specified [#81]' do
          schedule = Schedule.new(Time.new(2012, 5, 1))
          schedule.add_recurrence_rule Rule.daily.hour_of_day(8)
          times = schedule.occurrences_between(Time.new(2012, 05, 20), Time.new(2012, 05, 22))
          expect(times).to eq([
            Time.new(2012, 5, 20, 8, 0, 0),
            Time.new(2012, 5, 21, 8, 0, 0)
          ])
        end

        it 'should not include exception times due to rounding errors [#83]' do
          schedule = Schedule.new(t0 = Time.new(2012, 12, 21, 21, 12, 21.212121))
          schedule.rrule Rule.daily
          schedule.extime((t0 + ONE_DAY).round)
          expect(schedule.first(2)[0]).to eq(t0)
          expect(schedule.first(2)[1]).to eq(t0 + 2 * ONE_DAY)
        end

        it 'should return true if a recurring schedule occurs_between? a time range [#88]' do
          t0 = Time.new(2012, 7, 7, 8)
          schedule = Schedule.new(t0, :duration => 2 * ONE_HOUR)
          schedule.add_recurrence_rule Rule.weekly
          t0 = Time.new(2012, 7, 14, 9)
          t1 = Time.new(2012, 7, 14, 11)
          expect(schedule.occurring_between?(t0, t1)).to be_truthy
        end

        require 'active_support/time'

        it 'should not hang next_time on DST boundary [#98]', expect_warnings: true do # set local to Sweden
          schedule = Schedule.from_yaml <<-EOS
          :start_date: 2012-09-03 0:00:00.000000000 +00:00
          :end_time: 2022-09-15 0:00:00.000000000 +00:00
          :rrules:
          - :validations: {}
            :rule_type: IceCube::DailyRule
            :interval: 1
          :exrules: []
          :rtimes: []
          :extimes: []
          EOS
          expect(schedule.occurrences(Date.new(2013, 07, 13).to_time)).to be_a Array
        end

        it 'should still include date over DST boundary [#98]', expect_warnings: true do # set local to Sweden
          schedule = Schedule.from_yaml <<-EOS
          :start_date: 2012-09-03 15:00:00.000000000 +00:00
          :end_time: 2022-09-15 15:00:00.000000000 +00:00
          :rrules:
          - :validations: {}
            :rule_type: IceCube::DailyRule
            :interval: 1
          :exrules: []
          :rtimes: []
          :extimes: []
          EOS
          times = schedule.occurrences(Date.new(2013, 07, 13).to_time)
          expect(times.detect { |o| Date.new(o.year, o.month, o.day) == Date.new(2013, 3, 31) }).to be_truthy
        end

        it "failing spec for hanging on DST boundary [#98]" do
          Time.zone = "Europe/London"
          t0 = Time.zone.parse("Sun, 31 Mar 2013 00:00:00 GMT +00:00")
          schedule = Schedule.new(t0)
          schedule.add_recurrence_rule Rule.monthly
          expect(schedule.next_occurrence(t0)).to eq(Time.zone.local(2013, 4, 30))
        end

        it 'should exclude a date from a weekly schedule [#55]' do
          Time.zone = 'Eastern Time (US & Canada)'
          t0 = Time.zone.local(2011, 12, 27, 14)
          schedule = Schedule.new(t0) do |s|
            s.add_recurrence_rule Rule.weekly.day(:tuesday, :thursday)
            s.add_exception_time t0
          end
          expect(schedule.first).to eq(Time.zone.local(2011, 12, 29, 14))
        end

        it 'should not raise an exception after setting the rule until to nil' do
          rule = Rule.daily.until(Time.local(2012, 10, 1))
          rule.until(nil)
          schedule = Schedule.new Time.local(2011, 10, 11, 12)
          schedule.add_recurrence_rule rule

          expect {
            schedule.occurrences_between(Time.local(2012, 1, 1), Time.local(2012, 12, 1))
          }.to_not raise_error
        end

        it 'should not infinite loop [#109]' do
          schedule = Schedule.new(Time.new(2012, 4, 27, 0, 0, 0))
          schedule.rrule Rule.weekly.day(:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday).hour_of_day(0).minute_of_hour(0).second_of_minute(0)
          schedule.duration = 3600
          t1 = Time.new(2012, 10, 20, 0, 0, 0)
          t2 = Time.new(2012, 10, 20, 23, 59, 59)
          expect(schedule.occurrences_between(t1, t2).first).to eq(t1)
        end

        it 'should return next_occurrence in utc if start_time is utc [#115]' do
          schedule = Schedule.new(Time.utc(2012, 10, 10, 20, 15, 0))
          schedule.rrule Rule.daily
          expect(schedule.next_occurrence).to be_utc
        end

        it 'should return next_occurrence in local if start_time is local [#115]' do
          schedule = Schedule.new Time.new(2012, 10, 10, 20, 15, 0)
          schedule.rrule Rule.daily
          expect(schedule.next_occurrence).not_to be_utc
        end

        it 'should return next_occurrence in local by default [#115]' do
          schedule = Schedule.new
          schedule.rrule Rule.daily
          expect(schedule.next_occurrence).not_to be_utc
        end

        it 'should include occurrences on until _date_ [#118]' do
          start_time = Time.new(2012, 4, 27)
          schedule = Schedule.new(start_time)
          schedule.rrule Rule.daily.hour_of_day(12).until(Date.new(2012, 4, 28))
          expect(schedule.all_occurrences).to eq [
            start_time,
            Time.new(2012, 4, 27, 12),
            Time.new(2012, 4, 28, 12),
          ]
        end

        it 'should strip usecs from arguments when finding occurrences' do
          schedule = Schedule.new(Time.utc(2012, 4, 1, 10, 00))
          schedule.rrule Rule.weekly
          time = schedule.occurrences_between(Time.utc(2012,5,1,10,00,00,4), Time.utc(2012, 5, 15)).first
          expect(time.usec).to eq(0)
        end

      end
    end

  end
end
