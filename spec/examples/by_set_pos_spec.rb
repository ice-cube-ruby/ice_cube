require File.dirname(__FILE__) + "/../spec_helper"

module IceCube
  describe WeeklyRule, "BYSETPOS" do
    it "should behave correctly" do
      # Weekly on Monday, Wednesday, and Friday with the week starting on Wednesday, the last day of the set
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;WKST=WE;BYDAY=MO,WE,FR;BYSETPOS=-1")
      schedule.start_time = Time.new(2022, 12, 27, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2022, 1, 1), Time.new(2024, 1, 1)))
        .to eq([
          Time.new(2023, 1, 2, 12, 0, 0),
          Time.new(2023, 1, 9, 12, 0, 0),
          Time.new(2023, 1, 16, 12, 0, 0),
          Time.new(2023, 1, 23, 12, 0, 0)
        ])
    end

    it "should work with intervals" do
      # Every 2 weeks on Monday, Wednesday, and Friday with the week starting on Wednesday, the last day of the set
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;INTERVAL=2;WKST=WE;BYDAY=MO,WE,FR;BYSETPOS=-1")
      schedule.start_time = Time.new(2022, 12, 27, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2022, 1, 1), Time.new(2024, 1, 1)))
        .to eq([
          Time.new(2023, 1, 9, 12, 0, 0),
          Time.new(2023, 1, 23, 12, 0, 0),
          Time.new(2023, 2, 6, 12, 0, 0),
          Time.new(2023, 2, 20, 12, 0, 0)
        ])
    end

    it "should support positive positions" do
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;BYDAY=MO,WE;BYSETPOS=1")
      schedule.start_time = Time.new(2023, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 2, 1)))
        .to eq([
          Time.new(2023, 1, 2, 9, 0, 0),
          Time.new(2023, 1, 9, 9, 0, 0),
          Time.new(2023, 1, 16, 9, 0, 0),
          Time.new(2023, 1, 23, 9, 0, 0)
        ])
    end

    it "should support multiple positive positions" do
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=6;BYDAY=MO,WE,FR;BYSETPOS=1,3")
      schedule.start_time = Time.new(2023, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 2, 1)))
        .to eq([
          Time.new(2023, 1, 2, 9, 0, 0),
          Time.new(2023, 1, 6, 9, 0, 0),
          Time.new(2023, 1, 9, 9, 0, 0),
          Time.new(2023, 1, 13, 9, 0, 0),
          Time.new(2023, 1, 16, 9, 0, 0),
          Time.new(2023, 1, 20, 9, 0, 0)
        ])
    end

    it "should support mixed positive and negative positions" do
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;BYDAY=MO,WE,FR;BYSETPOS=1,-1")
      schedule.start_time = Time.new(2023, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 2, 1)))
        .to eq([
          Time.new(2023, 1, 2, 9, 0, 0),
          Time.new(2023, 1, 6, 9, 0, 0),
          Time.new(2023, 1, 9, 9, 0, 0),
          Time.new(2023, 1, 13, 9, 0, 0)
        ])
    end

    it "should work with hour expansions" do
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;BYDAY=MO;BYHOUR=1,2;BYSETPOS=2")
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 2, 1)))
        .to eq([
          Time.new(2023, 1, 2, 2, 0, 0),
          Time.new(2023, 1, 9, 2, 0, 0),
          Time.new(2023, 1, 16, 2, 0, 0),
          Time.new(2023, 1, 23, 2, 0, 0)
        ])
    end

    it "should ignore repeated positions" do
      # Duplicated BYSETPOS values should not duplicate occurrences.
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=3;BYDAY=MO,WE;BYSETPOS=1,1")
      schedule.start_time = Time.new(2023, 1, 2, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 2, 1)))
        .to eq([
          Time.new(2023, 1, 2, 9, 0, 0),
          Time.new(2023, 1, 9, 9, 0, 0),
          Time.new(2023, 1, 16, 9, 0, 0)
        ])
    end

    it "should return empty when BYSETPOS exceeds set size" do
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=2;BYDAY=MO,WE;BYSETPOS=3")
      schedule.start_time = Time.new(2023, 1, 2, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 2, 1)))
        .to eq([])
    end

    it "should respect until limits" do
      # UNTIL should be applied after BYSETPOS selection within the interval.
      schedule = IceCube::Schedule.new(Time.new(2023, 1, 2, 9, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.weekly.day(:monday, :wednesday).by_set_pos(-1).until(Time.new(2023, 1, 3, 9, 0, 0))
      )
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 2, 1)))
        .to eq([])
    end

    it "should include start_time when it matches the BYSETPOS position" do
      # Jan 4, 2023 is Wednesday, the 2nd day in week [Mon, Wed, Fri]
      schedule = IceCube::Schedule.new(Time.new(2023, 1, 4, 9, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.weekly.day(:monday, :wednesday, :friday).by_set_pos(2).count(4)
      )
      expect(schedule.all_occurrences).to eq([
        Time.new(2023, 1, 4, 9, 0, 0),
        Time.new(2023, 1, 11, 9, 0, 0),
        Time.new(2023, 1, 18, 9, 0, 0),
        Time.new(2023, 1, 25, 9, 0, 0)
      ])
    end
  end

  describe MonthlyRule, "BYSETPOS" do
    it "should behave correctly" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYDAY=WE;BYSETPOS=4"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([
          Time.new(2015, 6, 24, 12, 0, 0),
          Time.new(2015, 7, 22, 12, 0, 0),
          Time.new(2015, 8, 26, 12, 0, 0),
          Time.new(2015, 9, 23, 12, 0, 0)
        ])
    end

    it "should work with intervals" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYDAY=WE;BYSETPOS=4;INTERVAL=2"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([
          Time.new(2015, 7, 22, 12, 0, 0),
          Time.new(2015, 9, 23, 12, 0, 0),
          Time.new(2015, 11, 25, 12, 0, 0),
          Time.new(2016, 1, 27, 12, 0, 0)
        ])
    end

    it "should support negative positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYDAY=WE;BYSETPOS=-1"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([
          Time.new(2015, 6, 24, 12, 0, 0),
          Time.new(2015, 7, 29, 12, 0, 0),
          Time.new(2015, 8, 26, 12, 0, 0),
          Time.new(2015, 9, 30, 12, 0, 0)
        ])
    end

    it "should support multiple positions with monthday expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=3;BYMONTHDAY=1,15,30;BYSETPOS=2"
      schedule.start_time = Time.new(2015, 5, 1, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2015, 12, 1)))
        .to eq([
          Time.new(2015, 5, 15, 12, 0, 0),
          Time.new(2015, 6, 15, 12, 0, 0),
          Time.new(2015, 7, 15, 12, 0, 0)
        ])
    end

    it "should support multiple positions within the month" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYMONTHDAY=1,15,30;BYSETPOS=1,2"
      schedule.start_time = Time.new(2015, 5, 1, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2015, 8, 1)))
        .to eq([
          Time.new(2015, 5, 1, 12, 0, 0),
          Time.new(2015, 5, 15, 12, 0, 0),
          Time.new(2015, 6, 1, 12, 0, 0),
          Time.new(2015, 6, 15, 12, 0, 0)
        ])
    end

    it "should ignore repeated positions" do
      # Duplicated BYSETPOS values should not duplicate occurrences.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=3;BYMONTHDAY=10,20;BYSETPOS=1,1"
      schedule.start_time = Time.new(2015, 5, 1, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2015, 10, 1)))
        .to eq([
          Time.new(2015, 5, 10, 12, 0, 0),
          Time.new(2015, 6, 10, 12, 0, 0),
          Time.new(2015, 7, 10, 12, 0, 0)
        ])
    end

    it "should return empty when BYSETPOS exceeds set size" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=2;BYMONTHDAY=10,20;BYSETPOS=3"
      schedule.start_time = Time.new(2015, 5, 1, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2015, 10, 1)))
        .to eq([])
    end

    it "should respect until limits" do
      # UNTIL should be applied after BYSETPOS selection within the month.
      schedule = IceCube::Schedule.new(Time.new(2015, 5, 1, 12, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.monthly.day_of_month(10, 20).by_set_pos(2).until(Time.new(2015, 5, 15, 12, 0, 0))
      )
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2015, 10, 1)))
        .to eq([])
    end

    it "should apply after multiple BYxxx filters" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYDAY=MO,TU,WE,TH,FR;BYMONTHDAY=13,14,15;BYSETPOS=-1"
      schedule.start_time = Time.new(2019, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2019, 1, 1), Time.new(2019, 5, 1)))
        .to eq([
          Time.new(2019, 1, 15, 9, 0, 0),
          Time.new(2019, 2, 15, 9, 0, 0),
          Time.new(2019, 3, 15, 9, 0, 0),
          Time.new(2019, 4, 15, 9, 0, 0)
        ])
    end

    it "should work with byminute expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYMINUTE=1,2;BYSETPOS=2"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([
          Time.new(2015, 5, 28, 12, 2, 0),
          Time.new(2015, 6, 28, 12, 2, 0),
          Time.new(2015, 7, 28, 12, 2, 0),
          Time.new(2015, 8, 28, 12, 2, 0)
        ])
    end

    it "should work with bysecond expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYSECOND=1,2,3,4;BYSETPOS=2"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([
          Time.new(2015, 5, 28, 12, 0, 2),
          Time.new(2015, 6, 28, 12, 0, 2),
          Time.new(2015, 7, 28, 12, 0, 2),
          Time.new(2015, 8, 28, 12, 0, 2)
        ])
    end

    it "should preserve implicit minute anchor with bysecond expansions" do
      # BYSECOND should not reset the minute inherited from the schedule start_time.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=2;BYSECOND=10,20;BYSETPOS=1"
      schedule.start_time = Time.new(2015, 5, 28, 12, 30, 5)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2015, 12, 1)))
        .to eq([
          Time.new(2015, 5, 28, 12, 30, 10),
          Time.new(2015, 6, 28, 12, 30, 10)
        ])
    end

    it "should not consume counts across multiple rules" do
      start_time = Time.new(2019, 1, 1)
      rule_a = "FREQ=MONTHLY;COUNT=12;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-1"
      rule_b = "FREQ=MONTHLY;COUNT=12;BYDAY=MO,TU,WE,TH,FR;BYMONTHDAY=13,14,15;BYSETPOS=-1"
      range_end = Time.new(2021, 1, 1)

      schedule = IceCube::Schedule.new(start_time)
      schedule.add_recurrence_rule(IceCube::Rule.from_ical(rule_a))
      schedule.add_recurrence_rule(IceCube::Rule.from_ical(rule_b))

      expected_a = IceCube::Schedule.new(start_time)
      expected_a.add_recurrence_rule(IceCube::Rule.from_ical(rule_a))
      expected_b = IceCube::Schedule.new(start_time)
      expected_b.add_recurrence_rule(IceCube::Rule.from_ical(rule_b))

      occurrences = schedule.occurrences_between(start_time, range_end)
      expected_occurrences = (expected_a.occurrences_between(start_time, range_end) +
        expected_b.occurrences_between(start_time, range_end)).sort
      expect(occurrences).to eq(expected_occurrences)
      expect(occurrences.size).to eq(24)
    end

    it "should include start_time when it matches the BYSETPOS position" do
      # July 11, 2023 IS the 2nd Tuesday of July
      schedule = IceCube::Schedule.new(Time.new(2023, 7, 11, 12, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.monthly.day(:tuesday).by_set_pos(2).count(4)
      )
      expect(schedule.all_occurrences).to eq([
        Time.new(2023, 7, 11, 12, 0, 0),
        Time.new(2023, 8, 8, 12, 0, 0),
        Time.new(2023, 9, 12, 12, 0, 0),
        Time.new(2023, 10, 10, 12, 0, 0)
      ])
    end
  end

  describe YearlyRule, "BYSETPOS" do
    it "should behave correctly" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1"
      schedule.start_time = Time.new(1966, 7, 5)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([
          Time.new(2015, 7, 31),
          Time.new(2016, 7, 31)
        ])
    end

    it "should work with intervals" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1;INTERVAL=2"
      schedule.start_time = Time.new(1966, 7, 5)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2023, 1, 1)))
        .to eq([
          Time.new(2016, 7, 31),
          Time.new(2018, 7, 31),
          Time.new(2020, 7, 31),
          Time.new(2022, 7, 31)
        ])
    end

    it "should work with counts" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1;COUNT=3"
      schedule.start_time = Time.new(2016, 1, 1)
      expect(schedule.occurrences_between(Time.new(2016, 1, 1), Time.new(2050, 1, 1)))
        .to eq([
          Time.new(2016, 7, 31),
          Time.new(2017, 7, 31),
          Time.new(2018, 7, 31)
        ])
    end

    it "should work with counts and intervals" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1;COUNT=3;INTERVAL=2"
      schedule.start_time = Time.new(2016, 1, 1)
      expect(schedule.occurrences_between(Time.new(2016, 1, 1), Time.new(2050, 1, 1)))
        .to eq([
          Time.new(2016, 7, 31),
          Time.new(2018, 7, 31),
          Time.new(2020, 7, 31)
        ])
    end

    it "should support multiple positive positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=4;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=1,2"
      schedule.start_time = Time.new(2015, 1, 1)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 12, 31)))
        .to eq([
          Time.new(2015, 7, 1),
          Time.new(2015, 7, 2),
          Time.new(2016, 7, 1),
          Time.new(2016, 7, 2)
        ])
    end

    it "should support multiple negative positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=4;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1,-2"
      schedule.start_time = Time.new(2015, 1, 1)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 12, 31)))
        .to eq([
          Time.new(2015, 7, 30),
          Time.new(2015, 7, 31),
          Time.new(2016, 7, 30),
          Time.new(2016, 7, 31)
        ])
    end

    it "should work with byhour expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=2;BYMONTH=7;BYHOUR=1,2;BYSETPOS=1"
      schedule.start_time = Time.new(2016, 7, 5, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2016, 1, 1), Time.new(2018, 1, 1)))
        .to eq([
          Time.new(2016, 7, 5, 1, 0, 0),
          Time.new(2017, 7, 5, 1, 0, 0)
        ])
    end

    it "should preserve implicit minute/second anchor with byhour expansions" do
      # BYHOUR should not reset the minute/second inherited from the schedule start_time.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=2;BYMONTH=7;BYHOUR=1,2;BYSETPOS=2"
      schedule.start_time = Time.new(2016, 7, 5, 0, 45, 30)
      expect(schedule.occurrences_between(Time.new(2016, 1, 1), Time.new(2018, 1, 1)))
        .to eq([
          Time.new(2016, 7, 5, 2, 45, 30),
          Time.new(2017, 7, 5, 2, 45, 30)
        ])
    end

    it "should ignore repeated positions" do
      # Duplicated BYSETPOS values should not duplicate occurrences.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=2;BYMONTH=7;BYMONTHDAY=1,2;BYSETPOS=1,1"
      schedule.start_time = Time.new(2015, 1, 1)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([
          Time.new(2015, 7, 1),
          Time.new(2016, 7, 1)
        ])
    end

    it "should return empty when BYSETPOS exceeds set size" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=2;BYMONTH=7;BYMONTHDAY=1,2;BYSETPOS=3"
      schedule.start_time = Time.new(2015, 1, 1)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([])
    end

    it "should respect until limits" do
      # UNTIL should be applied after BYSETPOS selection within the year.
      schedule = IceCube::Schedule.new(Time.new(2015, 1, 1))
      schedule.add_recurrence_rule(
        IceCube::Rule.yearly.month_of_year(7).day_of_month(1, 2).by_set_pos(2).until(Time.new(2015, 7, 1))
      )
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2016, 1, 1)))
        .to eq([])
    end

    it "should select positive positions within a BYYEARDAY set" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=2;BYYEARDAY=1,10,20;BYSETPOS=2"
      schedule.start_time = Time.new(2015, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([
          Time.new(2015, 1, 10, 9, 0, 0),
          Time.new(2016, 1, 10, 9, 0, 0)
        ])
    end

    it "should select negative positions within a BYYEARDAY set" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=2;BYYEARDAY=1,10,20;BYSETPOS=-1"
      schedule.start_time = Time.new(2015, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([
          Time.new(2015, 1, 20, 9, 0, 0),
          Time.new(2016, 1, 20, 9, 0, 0)
        ])
    end

    it "should return empty when BYSETPOS exceeds a BYYEARDAY set" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=2;BYYEARDAY=1,10,20;BYSETPOS=4"
      schedule.start_time = Time.new(2015, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([])
    end

    it "should apply BYSETPOS before COUNT and UNTIL for BYYEARDAY" do
      schedule = IceCube::Schedule.new(Time.new(2015, 1, 1, 9, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.yearly.day_of_year(1, 10, 20).by_set_pos(2).count(2).until(Time.new(2015, 1, 5))
      )
      expect(schedule.occurrences_between(Time.new(2015, 1, 1), Time.new(2017, 1, 1)))
        .to eq([])
    end

    it "should include start_time when it matches the BYSETPOS position" do
      # July 2, 2015 IS the 2nd day in July
      schedule = IceCube::Schedule.new(Time.new(2015, 7, 2, 9, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.yearly.month_of_year(7).day(
          :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday
        ).by_set_pos(2).count(3)
      )
      expect(schedule.all_occurrences).to eq([
        Time.new(2015, 7, 2, 9, 0, 0),
        Time.new(2016, 7, 2, 9, 0, 0),
        Time.new(2017, 7, 2, 9, 0, 0)
      ])
    end
  end

  describe DailyRule, "BYSETPOS" do
    it "should work with hour expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=DAILY;COUNT=4;BYHOUR=1,2;BYSETPOS=2"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 6)))
        .to eq([
          Time.new(2023, 1, 1, 2, 0, 0),
          Time.new(2023, 1, 2, 2, 0, 0),
          Time.new(2023, 1, 3, 2, 0, 0),
          Time.new(2023, 1, 4, 2, 0, 0)
        ])
    end

    it "should apply BYSETPOS per interval with INTERVAL > 1" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=DAILY;INTERVAL=2;COUNT=3;BYHOUR=1,2;BYSETPOS=2"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 8)))
        .to eq([
          Time.new(2023, 1, 1, 2, 0, 0),
          Time.new(2023, 1, 3, 2, 0, 0),
          Time.new(2023, 1, 5, 2, 0, 0)
        ])
    end

    it "should respect day boundaries when starting late" do
      # Ensures BYSETPOS grouping resets per day while preserving the start_time minute anchor.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=DAILY;COUNT=2;BYHOUR=1,2;BYSETPOS=1"
      schedule.start_time = Time.new(2023, 1, 1, 23, 30, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 5)))
        .to eq([
          Time.new(2023, 1, 2, 1, 30, 0),
          Time.new(2023, 1, 3, 1, 30, 0)
        ])
    end

    it "should ignore nonexistent local times in the BYSETPOS set", system_time_zone: "America/New_York" do
      # DST spring-forward skips 2:00 AM; the invalid time must not be counted.
      start_time = Time.local(2019, 3, 10, 0, 0, 0)
      schedule = IceCube::Schedule.new(start_time)
      schedule.add_recurrence_rule(
        IceCube::Rule.daily.count(1).hour_of_day(1, 2, 3).by_set_pos(2)
      )
      occurrences = schedule.occurrences_between(
        Time.local(2019, 3, 10, 0, 0, 0),
        Time.local(2019, 3, 11, 0, 0, 0)
      )
      expect(occurrences).to eq([
        Time.local(2019, 3, 10, 3, 0, 0)
      ])
    end

    it "should apply after multiple BYxxx expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=DAILY;COUNT=3;BYHOUR=9,10;BYMINUTE=15,45;BYSETPOS=3"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 5)))
        .to eq([
          Time.new(2023, 1, 1, 10, 15, 0),
          Time.new(2023, 1, 2, 10, 15, 0),
          Time.new(2023, 1, 3, 10, 15, 0)
        ])
    end

    it "should apply BYSETPOS before count" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=DAILY;COUNT=1;BYHOUR=1,2,3;BYSETPOS=-1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 5)))
        .to eq([
          Time.new(2023, 1, 1, 3, 0, 0)
        ])
    end

    it "should apply BYSETPOS before until" do
      # If UNTIL were applied before BYSETPOS, the 02:00 occurrence would be selected.
      schedule = IceCube::Schedule.new(Time.new(2023, 1, 1, 0, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.daily.hour_of_day(1, 2, 3).by_set_pos(-1).until(Time.new(2023, 1, 1, 2, 0, 0))
      )
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 2)))
        .to eq([])
    end

    it "should ignore repeated positions" do
      # Duplicated BYSETPOS values should not duplicate occurrences.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=DAILY;COUNT=3;BYHOUR=1,2;BYSETPOS=1,1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 6)))
        .to eq([
          Time.new(2023, 1, 1, 1, 0, 0),
          Time.new(2023, 1, 2, 1, 0, 0),
          Time.new(2023, 1, 3, 1, 0, 0)
        ])
    end

    it "should return empty when BYSETPOS exceeds set size" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=DAILY;COUNT=2;BYHOUR=1,2;BYSETPOS=3"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 6)))
        .to eq([])
    end

    it "should support negative positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=DAILY;COUNT=3;BYHOUR=1,2,3;BYSETPOS=-1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 6)))
        .to eq([
          Time.new(2023, 1, 1, 3, 0, 0),
          Time.new(2023, 1, 2, 3, 0, 0),
          Time.new(2023, 1, 3, 3, 0, 0)
        ])
    end

    it "should support multiple positions with minute expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=DAILY;BYMINUTE=10,20,30;BYSETPOS=1,-1"
      schedule.start_time = Time.new(2023, 1, 1, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 3)))
        .to eq([
          Time.new(2023, 1, 1, 12, 10, 0),
          Time.new(2023, 1, 1, 12, 30, 0),
          Time.new(2023, 1, 2, 12, 10, 0),
          Time.new(2023, 1, 2, 12, 30, 0)
        ])
    end

    it "should include start_time when it matches the BYSETPOS position" do
      # Starting at 2am, the 2nd hour in [1, 2, 3]
      schedule = IceCube::Schedule.new(Time.new(2023, 1, 1, 2, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.daily.hour_of_day(1, 2, 3).by_set_pos(2).count(3)
      )
      expect(schedule.all_occurrences).to eq([
        Time.new(2023, 1, 1, 2, 0, 0),
        Time.new(2023, 1, 2, 2, 0, 0),
        Time.new(2023, 1, 3, 2, 0, 0)
      ])
    end
  end

  describe HourlyRule, "BYSETPOS" do
    it "should work with minute expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=HOURLY;COUNT=4;BYMINUTE=10,20;BYSETPOS=2"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 5, 0, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 20, 0),
          Time.new(2023, 1, 1, 1, 20, 0),
          Time.new(2023, 1, 1, 2, 20, 0),
          Time.new(2023, 1, 1, 3, 20, 0)
        ])
    end

    it "should apply BYSETPOS per interval with INTERVAL > 1" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=HOURLY;INTERVAL=2;COUNT=3;BYMINUTE=10,20;BYSETPOS=1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 6, 0, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 10, 0),
          Time.new(2023, 1, 1, 2, 10, 0),
          Time.new(2023, 1, 1, 4, 10, 0)
        ])
    end

    it "should respect hour boundaries when starting late" do
      # Ensures BYSETPOS grouping resets per hour, not from the schedule start_time.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=HOURLY;COUNT=3;BYMINUTE=10,20;BYSETPOS=1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 45, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 5, 0, 0)))
        .to eq([
          Time.new(2023, 1, 1, 1, 10, 0),
          Time.new(2023, 1, 1, 2, 10, 0),
          Time.new(2023, 1, 1, 3, 10, 0)
        ])
    end

    it "should apply after multiple BYxxx expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=HOURLY;COUNT=3;BYMINUTE=10,20;BYSECOND=5,50;BYSETPOS=2"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 4, 0, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 10, 50),
          Time.new(2023, 1, 1, 1, 10, 50),
          Time.new(2023, 1, 1, 2, 10, 50)
        ])
    end

    it "should return no occurrences when BYSETPOS exceeds the set size" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=HOURLY;COUNT=2;BYMINUTE=10,20;BYSETPOS=3"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 2, 0, 0)))
        .to eq([])
    end

    it "should ignore repeated positions" do
      # Duplicated BYSETPOS values should not duplicate occurrences.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=HOURLY;COUNT=2;BYMINUTE=10,20;BYSETPOS=2,2"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 3, 0, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 20, 0),
          Time.new(2023, 1, 1, 1, 20, 0)
        ])
    end

    it "should respect until limits" do
      # UNTIL should be applied after BYSETPOS selection within the hour.
      schedule = IceCube::Schedule.new(Time.new(2023, 1, 1, 0, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.hourly.minute_of_hour(10, 20).by_set_pos(2).until(Time.new(2023, 1, 1, 0, 25, 0))
      )
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 2, 0, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 20, 0)
        ])
    end

    it "should support negative positions with second expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=HOURLY;COUNT=3;BYSECOND=5,10,15;BYSETPOS=-1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 34, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 4, 0, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 34, 15),
          Time.new(2023, 1, 1, 1, 34, 15),
          Time.new(2023, 1, 1, 2, 34, 15)
        ])
    end

    it "should support multiple positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=HOURLY;BYMINUTE=5,10,15;BYSETPOS=1,-1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 2, 0, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 5, 0),
          Time.new(2023, 1, 1, 0, 15, 0),
          Time.new(2023, 1, 1, 1, 5, 0),
          Time.new(2023, 1, 1, 1, 15, 0)
        ])
    end

    it "should include start_time when it matches the BYSETPOS position" do
      # Starting at minute 20, the 2nd minute in [10, 20, 30]
      schedule = IceCube::Schedule.new(Time.new(2023, 1, 1, 0, 20, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.hourly.minute_of_hour(10, 20, 30).by_set_pos(2).count(3)
      )
      expect(schedule.all_occurrences).to eq([
        Time.new(2023, 1, 1, 0, 20, 0),
        Time.new(2023, 1, 1, 1, 20, 0),
        Time.new(2023, 1, 1, 2, 20, 0)
      ])
    end
  end

  describe MinutelyRule, "BYSETPOS" do
    it "should work with second expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MINUTELY;COUNT=4;BYSECOND=5,10;BYSETPOS=2"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 5, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 0, 10),
          Time.new(2023, 1, 1, 0, 1, 10),
          Time.new(2023, 1, 1, 0, 2, 10),
          Time.new(2023, 1, 1, 0, 3, 10)
        ])
    end

    it "should apply BYSETPOS per interval with INTERVAL > 1" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MINUTELY;INTERVAL=5;COUNT=3;BYSECOND=10,20;BYSETPOS=-1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 20, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 0, 20),
          Time.new(2023, 1, 1, 0, 5, 20),
          Time.new(2023, 1, 1, 0, 10, 20)
        ])
    end

    it "should return empty when BYSETPOS exceeds set size" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MINUTELY;COUNT=2;BYSECOND=10,20;BYSETPOS=3"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 5, 0)))
        .to eq([])
    end

    it "should ignore repeated positions" do
      # Duplicated BYSETPOS values should not duplicate occurrences.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MINUTELY;COUNT=2;BYSECOND=10,20;BYSETPOS=1,1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 5, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 0, 10),
          Time.new(2023, 1, 1, 0, 1, 10)
        ])
    end

    it "should respect until limits" do
      # UNTIL should be applied after BYSETPOS selection within the minute.
      schedule = IceCube::Schedule.new(Time.new(2023, 1, 1, 0, 0, 0))
      schedule.add_recurrence_rule(
        IceCube::Rule.minutely.second_of_minute(10, 20).by_set_pos(2).until(Time.new(2023, 1, 1, 0, 0, 25))
      )
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 2, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 0, 20)
        ])
    end

    it "should respect minute boundaries when starting late" do
      # Ensures BYSETPOS grouping resets per minute, not from the schedule start_time.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MINUTELY;COUNT=3;BYSECOND=10,20;BYSETPOS=1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 45)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 5, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 1, 10),
          Time.new(2023, 1, 1, 0, 2, 10),
          Time.new(2023, 1, 1, 0, 3, 10)
        ])
    end

    it "should apply after BYxxx filters and expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MINUTELY;COUNT=3;BYHOUR=1;BYSECOND=10,20,30;BYSETPOS=2"
      schedule.start_time = Time.new(2023, 1, 1, 1, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 1, 5, 0)))
        .to eq([
          Time.new(2023, 1, 1, 1, 0, 20),
          Time.new(2023, 1, 1, 1, 1, 20),
          Time.new(2023, 1, 1, 1, 2, 20)
        ])
    end

    it "should support negative positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MINUTELY;COUNT=3;BYSECOND=1,2,3;BYSETPOS=-1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 4, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 0, 3),
          Time.new(2023, 1, 1, 0, 1, 3),
          Time.new(2023, 1, 1, 0, 2, 3)
        ])
    end

    it "should support multiple positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MINUTELY;BYSECOND=5,10,15;BYSETPOS=1,-1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 2, 0)))
        .to eq([
          Time.new(2023, 1, 1, 0, 0, 5),
          Time.new(2023, 1, 1, 0, 0, 15),
          Time.new(2023, 1, 1, 0, 1, 5),
          Time.new(2023, 1, 1, 0, 1, 15)
        ])
    end

    it "should include start_time when it matches the BYSETPOS position" do
      # Starting at second 20, the 2nd second in [10, 20, 30]
      schedule = IceCube::Schedule.new(Time.new(2023, 1, 1, 0, 0, 20))
      schedule.add_recurrence_rule(
        IceCube::Rule.minutely.second_of_minute(10, 20, 30).by_set_pos(2).count(3)
      )
      expect(schedule.all_occurrences).to eq([
        Time.new(2023, 1, 1, 0, 0, 20),
        Time.new(2023, 1, 1, 0, 1, 20),
        Time.new(2023, 1, 1, 0, 2, 20)
      ])
    end
  end

  # Regression tests for interval boundary anchoring issues
  describe "interval boundary anchoring" do
    # Finding 1: Sub-day expansions (BYHOUR/BYMINUTE/BYSECOND) should anchor to interval start
    context "sub-day expansions" do
      it "FREQ=DAILY with BYHOUR should anchor to start of day, not DTSTART" do
        # DTSTART is 9am, which is position 2 in [8, 9, 10].
        # The BYSETPOS validator must count from start of day to see [8am, 9am, 10am].
        # If it wrongly anchors to DTSTART (9am), it would only see [9am, 10am]
        # and 9am would appear at position 1 (not matching BYSETPOS=2).
        schedule = IceCube::Schedule.new(Time.new(2023, 1, 1, 9, 0, 0))
        schedule.add_recurrence_rule(
          IceCube::Rule.daily.hour_of_day(8, 9, 10).by_set_pos(2).count(3)
        )
        # If buggy: would return [10am Jan 1, 10am Jan 2, 10am Jan 3] (position 2 of truncated [9am, 10am])
        # If correct: [9am Jan 1, 9am Jan 2, 9am Jan 3] (position 2 of full [8am, 9am, 10am])
        expect(schedule.all_occurrences).to eq([
          Time.new(2023, 1, 1, 9, 0, 0),
          Time.new(2023, 1, 2, 9, 0, 0),
          Time.new(2023, 1, 3, 9, 0, 0)
        ])
      end

      it "FREQ=HOURLY with BYMINUTE should anchor to start of hour, not DTSTART" do
        # Starting at minute 30. With BYMINUTE=15,30,45 the candidate set is [15,30,45].
        # Position 2 = minute 30.
        # If anchored wrongly to minute 30, we'd see [30,45] and position 2 = 45.
        schedule = IceCube::Schedule.new(Time.new(2023, 1, 1, 0, 30, 0))
        schedule.add_recurrence_rule(
          IceCube::Rule.hourly.minute_of_hour(15, 30, 45).by_set_pos(2).count(3)
        )
        # If buggy: would return [:30, 1:30, 2:30] with position treated as 1 of truncated set
        # or [0:45, 1:45, 2:45] if position 2 of [30,45]
        # If correct: [0:30, 1:30, 2:30] (position 2 of full set [15,30,45])
        expect(schedule.all_occurrences).to eq([
          Time.new(2023, 1, 1, 0, 30, 0),
          Time.new(2023, 1, 1, 1, 30, 0),
          Time.new(2023, 1, 1, 2, 30, 0)
        ])
      end

      it "FREQ=MINUTELY with BYSECOND should anchor to start of minute, not DTSTART" do
        # Starting at second 30. With BYSECOND=15,30,45 the candidate set is [15,30,45].
        # Position 2 = second 30.
        schedule = IceCube::Schedule.new(Time.new(2023, 1, 1, 0, 0, 30))
        schedule.add_recurrence_rule(
          IceCube::Rule.minutely.second_of_minute(15, 30, 45).by_set_pos(2).count(3)
        )
        expect(schedule.all_occurrences).to eq([
          Time.new(2023, 1, 1, 0, 0, 30),
          Time.new(2023, 1, 1, 0, 1, 30),
          Time.new(2023, 1, 1, 0, 2, 30)
        ])
      end
    end

    # Finding 2: BYMONTH-only expansions should anchor to start of year (for yearly rules only)
    context "BYMONTH-only expansions" do
      it "FREQ=HOURLY with BYMONTH should NOT shift anchor date" do
        # DTSTART is Jan 31 at 10:00. BYMONTH=4 means only April.
        # For hourly rules, BYMONTH is just a filter, not an expansion within the interval.
        # The first April occurrence should be April 1 (at midnight, since hourly steps through all hours).
        # If buggy: anchor_date for April 1 would be April 30, rejecting all early April occurrences.
        schedule = IceCube::Schedule.new(Time.new(2023, 1, 31, 10, 0, 0))
        schedule.add_recurrence_rule(
          IceCube::Rule.hourly.month_of_year(4).by_set_pos(1).count(3)
        )
        # Key assertion: first occurrence is April 1, not April 30
        expect(schedule.first(3)).to eq([
          Time.new(2023, 4, 1, 0, 0, 0),
          Time.new(2023, 4, 1, 1, 0, 0),
          Time.new(2023, 4, 1, 2, 0, 0)
        ])
      end

      it "FREQ=YEARLY with BYMONTH should anchor to start of year, not DTSTART" do
        # Starting in February with BYMONTH=1,2,3 and BYSETPOS=2.
        # Candidate set for year should be [Jan, Feb, Mar].
        # Position 2 = February.
        # If anchored wrongly to DTSTART (February), we'd only see [Feb, Mar]
        # and position 2 = March.
        schedule = IceCube::Schedule.new(Time.new(2023, 2, 15, 9, 0, 0))
        schedule.add_recurrence_rule(
          IceCube::Rule.yearly.month_of_year(1, 2, 3).by_set_pos(2).count(3)
        )
        # If buggy: [Mar 15 2023, Mar 15 2024, Mar 15 2025] (position 2 of [Feb, Mar])
        # If correct: [Feb 15 2023, Feb 15 2024, Feb 15 2025] (position 2 of [Jan, Feb, Mar])
        expect(schedule.all_occurrences).to eq([
          Time.new(2023, 2, 15, 9, 0, 0),
          Time.new(2024, 2, 15, 9, 0, 0),
          Time.new(2025, 2, 15, 9, 0, 0)
        ])
      end

      it "FREQ=YEARLY with BYMONTH and BYSETPOS=-1 should select last month in set" do
        # Starting in January with BYMONTH=1,2,3 and BYSETPOS=-1.
        # Position -1 = March (last in set).
        schedule = IceCube::Schedule.new(Time.new(2023, 1, 15, 9, 0, 0))
        schedule.add_recurrence_rule(
          IceCube::Rule.yearly.month_of_year(1, 2, 3).by_set_pos(-1).count(3)
        )
        expect(schedule.all_occurrences).to eq([
          Time.new(2023, 3, 15, 9, 0, 0),
          Time.new(2024, 3, 15, 9, 0, 0),
          Time.new(2025, 3, 15, 9, 0, 0)
        ])
      end
    end
  end

  describe SecondlyRule, "BYSETPOS" do
    it "should allow BYSETPOS without other BYxxx parts" do
      # RFC requires another BYxxx, but IceCube permits this for convenience.
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=SECONDLY;COUNT=3;BYSETPOS=1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 0, 10)))
        .to eq([
          Time.new(2023, 1, 1, 0, 0, 0),
          Time.new(2023, 1, 1, 0, 0, 1),
          Time.new(2023, 1, 1, 0, 0, 2)
        ])
    end

    it "should apply BYSETPOS per interval with INTERVAL > 1" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=SECONDLY;INTERVAL=2;COUNT=3;BYSETPOS=1"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 0, 10)))
        .to eq([
          Time.new(2023, 1, 1, 0, 0, 0),
          Time.new(2023, 1, 1, 0, 0, 2),
          Time.new(2023, 1, 1, 0, 0, 4)
        ])
    end

    it "should return empty when BYSETPOS exceeds set size" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=SECONDLY;COUNT=2;BYSETPOS=2"
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 1, 1), Time.new(2023, 1, 1, 0, 0, 10)))
        .to eq([])
    end
  end

  describe "Edge cases" do
    it "should preserve sub-second precision with BYSETPOS" do
      # Start time with microseconds (fractional seconds)
      start_time = Time.new(2023, 1, 1, 12, 0, 0.123456, "+00:00")
      schedule = IceCube::Schedule.new(start_time)
      schedule.add_recurrence_rule IceCube::Rule.daily.hour_of_day(9, 12, 15).by_set_pos(2)

      occurrences = schedule.first(3)
      # Each occurrence should preserve the microseconds from the start time
      # Due to floating point representation, we allow a small delta (within 10 microseconds)
      occurrences.each do |occ|
        expect(occ.usec).to be_within(10).of(123456), "Expected microseconds to be preserved, got #{occ.usec} for #{occ}"
      end
    end

    it "should work with very large intervals (INTERVAL=100)" do
      # Test that BYSETPOS works with large intervals
      start_time = Time.new(2023, 1, 1, 0, 0, 0)
      schedule = IceCube::Schedule.new(start_time)
      schedule.add_recurrence_rule IceCube::Rule.monthly(100).day(:monday).by_set_pos(1)

      first_occurrence = schedule.first
      second_occurrence = schedule.occurrences_between(start_time, start_time + 10000 * IceCube::ONE_DAY)[1]

      expect(first_occurrence).to eq(Time.new(2023, 1, 2, 0, 0, 0)) # First Monday in Jan 2023
      # Second occurrence should be 100 months later
      expect(second_occurrence).to eq(Time.new(2031, 5, 5, 0, 0, 0)) # First Monday in May 2031 (100 months later)
    end

    it "should handle INTERVAL=50 with BYSETPOS on yearly rules" do
      start_time = Time.new(2000, 1, 1, 0, 0, 0)
      schedule = IceCube::Schedule.new(start_time)
      schedule.add_recurrence_rule IceCube::Rule.yearly(50).month_of_year(:january, :december).by_set_pos(-1)

      occurrences = schedule.first(3)
      # Should get December in years 2000, 2050, 2100
      expect(occurrences.map { |t| [t.year, t.month] }).to eq([
        [2000, 12],
        [2050, 12],
        [2100, 12]
      ])
    end

    it "should handle BYYEARDAY=366 with BYSETPOS in non-leap years" do
      # 2023 is not a leap year
      start_time = Time.new(2023, 1, 1, 0, 0, 0)
      schedule = IceCube::Schedule.new(start_time)
      schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(365, 366).by_set_pos(-1)

      # In non-leap years, day 366 doesn't exist, so should only get day 365
      first_occurrence = schedule.first
      expect(first_occurrence).to eq(Time.new(2023, 12, 31, 0, 0, 0))

      # In 2024 (leap year), should get day 366
      second_occurrence = schedule.occurrences_between(start_time, start_time + 3 * 365 * IceCube::ONE_DAY)[1]
      expect(second_occurrence).to eq(Time.new(2024, 12, 31, 0, 0, 0)) # Day 366 in leap year
    end

    it "should handle BYYEARDAY=366 with BYSETPOS=1 in leap year" do
      # 2024 is a leap year
      start_time = Time.new(2024, 1, 1, 0, 0, 0)
      schedule = IceCube::Schedule.new(start_time)
      schedule.add_recurrence_rule IceCube::Rule.yearly.day_of_year(365, 366).by_set_pos(1)

      # Should get day 365 (first position)
      first_occurrence = schedule.first
      expect(first_occurrence).to eq(Time.new(2024, 12, 30, 0, 0, 0))
    end

    it "should preserve nanosecond precision with BYSETPOS" do
      # Ruby Time objects support nanosecond precision
      start_time = Time.new(2023, 1, 1, 12, 0, 0.123456789, "+00:00")
      schedule = IceCube::Schedule.new(start_time)
      schedule.add_recurrence_rule IceCube::Rule.weekly.day(:monday, :wednesday).by_set_pos(1)

      occurrences = schedule.first(3)
      # Each occurrence should preserve the sub-second precision from the start time
      # Due to floating point representation, we allow a small delta (within 1 nanosecond)
      occurrences.each do |occ|
        expect(occ.nsec).to be_within(1).of(123456789), "Expected nanoseconds to be preserved, got #{occ.nsec} for #{occ}"
      end
    end

    it "should handle INTERVAL=1000 with BYSETPOS on daily rules" do
      start_time = Time.new(2023, 1, 1, 0, 0, 0)
      schedule = IceCube::Schedule.new(start_time)
      schedule.add_recurrence_rule IceCube::Rule.daily(1000).hour_of_day(6, 12, 18).by_set_pos(2)

      first_occurrence = schedule.first
      # Should get 12:00 (second position) on day 1
      expect(first_occurrence).to eq(Time.new(2023, 1, 1, 12, 0, 0))

      # Second occurrence should be 1000 days later
      second_occurrence = schedule.occurrences_between(start_time, start_time + 1500 * IceCube::ONE_DAY)[1]
      expect(second_occurrence).to eq(Time.new(2025, 9, 27, 12, 0, 0)) # 1000 days later
    end
  end
end
