require File.dirname(__FILE__) + '/../spec_helper'
require 'active_support/time'

module IceCube

  describe Rule, 'from_ical' do

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

    it 'should be able to parse a rule with an interval' do
      rule = IceCube::Rule.from_ical("FREQ=DAILY;INTERVAL=2")
      rule.should == IceCube::Rule.daily.interval(2)
    end

    it 'should be able to parse week start (WKST)' do
      rule = IceCube::Rule.from_ical("FREQ=WEEKLY;INTERVAL=2;WKST=MO")
      rule.should == IceCube::Rule.weekly(2, :monday)
    end

    it 'should return no occurrences after daily interval with count is over' do
      schedule = IceCube::Schedule.new(Time.now)
      schedule.add_recurrence_rule(IceCube::Rule.from_ical("FREQ=DAILY;COUNT=5"))
      schedule.occurrences_between(Time.now + 7.days, Time.now + 14.days).count.should == 0
    end

  end

  describe Schedule, 'from_ical', system_time_zone: "America/Chicago" do

    ical_string = <<-ICAL.gsub(/^\s*/, '')
  DTSTART:20130314T201500Z
  DTEND:20130314T201545Z
  RRULE:FREQ=WEEKLY;BYDAY=TH;UNTIL=20130531T100000Z
  ICAL

    ical_string_with_time_zones = <<-ICAL.gsub(/^\s*/,'')
  DTSTART;TZID=America/Denver:20130731T143000
  DTEND:20130731T153000
  RRULE:FREQ=WEEKLY
  EXDATE;TZID=America/Chicago:20130823T143000
  ICAL

    ical_string_with_multiple_exdates = <<-ICAL.gsub(/^\s*/, '')
  DTSTART;TZID=America/Denver:20130731T143000
  DTEND;TZID=America/Denver:20130731T153000
  RRULE:FREQ=WEEKLY;UNTIL=20140730T203000Z;BYDAY=MO,WE,FR
  EXDATE;TZID=America/Denver:20130823T143000
  EXDATE;TZID=America/Denver:20130812T143000
  EXDATE;TZID=America/Denver:20130807T143000
  ICAL


    def sorted_ical(ical)
      ical.split(/\n/).sort.map { |field|
        k, v = field.split(':')
        v = v.split(';').sort.join(';') if k == 'RRULE'

        "#{ k }:#{ v }"
      }.join("\n")
    end

    describe "instantiation" do
      it "loads an ICAL string" do
        expect(IceCube::Schedule.from_ical(ical_string)).to be_a(IceCube::Schedule)
      end
      describe "parsing time zones" do
        it "sets the time zone of the start time" do
          schedule = IceCube::Schedule.from_ical(ical_string_with_time_zones)
          expect(schedule.start_time.time_zone).to eq ActiveSupport::TimeZone.new("America/Denver")
        end
        it "uses the system time if a time zone is not explicity provided" do
          schedule = IceCube::Schedule.from_ical(ical_string_with_time_zones)
          expect(schedule.end_time).not_to respond_to :time_zone
        end
        it "sets the time zone of the exception times" do
          schedule = IceCube::Schedule.from_ical(ical_string_with_time_zones)
          expect(schedule.exception_times[0].time_zone).to eq ActiveSupport::TimeZone.new("America/Chicago")
        end
        it "adding the offset doesnt also change the time" do
          schedule = IceCube::Schedule.from_ical(ical_string_with_time_zones)
          expect(schedule.exception_times[0].hour).to eq 14
        end
      end
    end

    describe "daily frequency" do
      it 'matches simple daily' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.daily)

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles counts' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.daily.count(4))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles intervals' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.daily(4))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles intervals and counts' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.daily(4).count(10))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles until dates' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.daily.until(start_time + 15.days))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

    end

    describe 'weekly frequency' do
      it 'matches simple weekly' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.weekly)

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles weekdays' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.weekly.day(:monday, :thursday))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles intervals' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.weekly(2))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles intervals and counts' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.weekly(2).count(4))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles intervals and counts on given weekdays' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.weekly(2).day(:monday, :wednesday).count(4))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end
    end

    describe 'monthly frequency' do
      it 'matches simple monthly' do
        start_time = Time.now
        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.monthly)

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles intervals' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.monthly(2))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles intervals and counts' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.monthly(2).count(5))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles intervals and counts on specific days' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.monthly(2).day_of_month(1, 15).count(5))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end
    end

    describe 'yearly frequency' do
      it 'matches simple yearly' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.yearly)

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles intervals' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.yearly(2))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles a specific day' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.yearly.day_of_year(15))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles specific days' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.yearly.day_of_year(1, 15, -1))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles counts' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.yearly.count(5))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles specific months' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.yearly.month_of_year(:january, :december))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles specific months and counts' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.yearly.month_of_year(:january, :december).count(15))

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end
    end

    describe "exceptions" do
      it 'handles single EXDATE lines' do
        start_time = Time.now

        schedule = IceCube::Schedule.new(start_time)
        schedule.add_recurrence_rule(IceCube::Rule.daily)
        schedule.add_exception_time(Time.now + 2.days)

        ical = schedule.to_ical
        sorted_ical(IceCube::Schedule.from_ical(ical).to_ical).should eq(sorted_ical(ical))
      end

      it 'handles multiple EXDATE lines' do
        schedule = IceCube::Schedule.from_ical ical_string_with_multiple_exdates
        schedule.exception_times.count.should == 3
      end
    end
  end

end
