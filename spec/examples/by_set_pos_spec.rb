require File.dirname(__FILE__) + "/../spec_helper"

module IceCube
  describe WeeklyRule, "BYSETPOS" do
    it "should behave correctly" do
      # Weekly on Monday, Wednesday, and Friday with the week starting on Wednesday, the last day of the set
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;WKST=WE;BYDAY=MO,WE,FR;BYSETPOS=-1")
      schedule.start_time = Time.new(2022, 12, 27, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2022, 01, 01), Time.new(2024, 01, 01))).
        to eq([
          Time.new(2023,1,2,12,0,0),
          Time.new(2023,1,9,12,0,0),
          Time.new(2023,1,16,12,0,0),
          Time.new(2023,1,23,12,0,0)
        ])
    end

    it "should work with intervals" do
      # Every 2 weeks on Monday, Wednesday, and Friday with the week starting on Wednesday, the last day of the set
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;INTERVAL=2;WKST=WE;BYDAY=MO,WE,FR;BYSETPOS=-1")
      schedule.start_time = Time.new(2022, 12, 27, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2022, 01, 01), Time.new(2024, 01, 01))).
        to eq([
          Time.new(2023,1,9,12,0,0),
          Time.new(2023,1,23,12,0,0),
          Time.new(2023,2,6,12,0,0),
          Time.new(2023,2,20,12,0,0)
        ])
    end

    it "should support positive positions" do
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;BYDAY=MO,WE;BYSETPOS=1")
      schedule.start_time = Time.new(2023, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 01, 01), Time.new(2023, 02, 01))).
        to eq([
          Time.new(2023,1,2,9,0,0),
          Time.new(2023,1,9,9,0,0),
          Time.new(2023,1,16,9,0,0),
          Time.new(2023,1,23,9,0,0)
        ])
    end

    it "should support multiple positive positions" do
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=6;BYDAY=MO,WE,FR;BYSETPOS=1,3")
      schedule.start_time = Time.new(2023, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 01, 01), Time.new(2023, 02, 01))).
        to eq([
          Time.new(2023,1,2,9,0,0),
          Time.new(2023,1,6,9,0,0),
          Time.new(2023,1,9,9,0,0),
          Time.new(2023,1,13,9,0,0),
          Time.new(2023,1,16,9,0,0),
          Time.new(2023,1,20,9,0,0)
        ])
    end

    it "should support mixed positive and negative positions" do
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;BYDAY=MO,WE,FR;BYSETPOS=1,-1")
      schedule.start_time = Time.new(2023, 1, 1, 9, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 01, 01), Time.new(2023, 02, 01))).
        to eq([
          Time.new(2023,1,2,9,0,0),
          Time.new(2023,1,6,9,0,0),
          Time.new(2023,1,9,9,0,0),
          Time.new(2023,1,13,9,0,0)
        ])
    end

    it "should work with hour expansions" do
      schedule = IceCube::Schedule.from_ical("RRULE:FREQ=WEEKLY;COUNT=4;BYDAY=MO;BYHOUR=1,2;BYSETPOS=2")
      schedule.start_time = Time.new(2023, 1, 1, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2023, 01, 01), Time.new(2023, 02, 01))).
        to eq([
          Time.new(2023,1,2,2,0,0),
          Time.new(2023,1,9,2,0,0),
          Time.new(2023,1,16,2,0,0),
          Time.new(2023,1,23,2,0,0)
        ])
    end
  end

  describe MonthlyRule, "BYSETPOS" do
    it "should behave correctly" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYDAY=WE;BYSETPOS=4"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 01, 01))).
        to eq([
          Time.new(2015,6,24,12,0,0),
          Time.new(2015,7,22,12,0,0),
          Time.new(2015,8,26,12,0,0),
          Time.new(2015,9,23,12,0,0)
        ])
    end

    it "should work with intervals" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYDAY=WE;BYSETPOS=4;INTERVAL=2"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 01, 01))).
        to eq([
          Time.new(2015,7,22,12,0,0),
          Time.new(2015,9,23,12,0,0),
          Time.new(2015,11,25,12,0,0),
          Time.new(2016,1,27,12,0,0),
        ])
    end

    it "should support negative positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYDAY=WE;BYSETPOS=-1"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 01, 01))).
        to eq([
          Time.new(2015,6,24,12,0,0),
          Time.new(2015,7,29,12,0,0),
          Time.new(2015,8,26,12,0,0),
          Time.new(2015,9,30,12,0,0)
        ])
    end

    it "should support multiple positions with monthday expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=3;BYMONTHDAY=1,15,30;BYSETPOS=2"
      schedule.start_time = Time.new(2015, 5, 1, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2015, 12, 01))).
        to eq([
          Time.new(2015,5,15,12,0,0),
          Time.new(2015,6,15,12,0,0),
          Time.new(2015,7,15,12,0,0)
        ])
    end

    it "should work with byminute expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYMINUTE=1,2;BYSETPOS=2"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 01, 01))).
        to eq([
          Time.new(2015,5,28,12,2,0),
          Time.new(2015,6,28,12,2,0),
          Time.new(2015,7,28,12,2,0),
          Time.new(2015,8,28,12,2,0)
        ])
    end

    it "should work with bysecond expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=MONTHLY;COUNT=4;BYSECOND=1,2,3,4;BYSETPOS=2"
      schedule.start_time = Time.new(2015, 5, 28, 12, 0, 0)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 01, 01))).
        to eq([
          Time.new(2015,5,28,12,0,2),
          Time.new(2015,6,28,12,0,2),
          Time.new(2015,7,28,12,0,2),
          Time.new(2015,8,28,12,0,2)
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
  end

  describe YearlyRule, "BYSETPOS" do
    it "should behave correctly" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1"
      schedule.start_time = Time.new(1966,7,5)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 01, 01))).
        to eq([
          Time.new(2015, 7, 31),
          Time.new(2016, 7, 31)
        ])
    end

    it "should work with intervals" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1;INTERVAL=2"
      schedule.start_time = Time.new(1966,7,5)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2023, 01, 01))).
        to eq([
          Time.new(2016, 7, 31),
          Time.new(2018, 7, 31),
          Time.new(2020, 7, 31),
          Time.new(2022, 7, 31),
        ])
    end

    it "should work with counts" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1;COUNT=3"
      schedule.start_time = Time.new(2016,1,1)
      expect(schedule.occurrences_between(Time.new(2016, 01, 01), Time.new(2050, 01, 01))).
        to eq([
          Time.new(2016, 7, 31),
          Time.new(2017, 7, 31),
          Time.new(2018, 7, 31),
        ])
    end

    it "should work with counts and intervals" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1;COUNT=3;INTERVAL=2"
      schedule.start_time = Time.new(2016,1,1)
      expect(schedule.occurrences_between(Time.new(2016, 01, 01), Time.new(2050, 01, 01))).
        to eq([
          Time.new(2016, 7, 31),
          Time.new(2018, 7, 31),
          Time.new(2020, 7, 31),
        ])
    end

    it "should support multiple positive positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=4;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=1,2"
      schedule.start_time = Time.new(2015, 1, 1)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 12, 31))).
        to eq([
          Time.new(2015, 7, 1),
          Time.new(2015, 7, 2),
          Time.new(2016, 7, 1),
          Time.new(2016, 7, 2)
        ])
    end

    it "should support multiple negative positions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=4;BYMONTH=7;BYDAY=SU,MO,TU,WE,TH,FR,SA;BYSETPOS=-1,-2"
      schedule.start_time = Time.new(2015, 1, 1)
      expect(schedule.occurrences_between(Time.new(2015, 01, 01), Time.new(2017, 12, 31))).
        to eq([
          Time.new(2015, 7, 30),
          Time.new(2015, 7, 31),
          Time.new(2016, 7, 30),
          Time.new(2016, 7, 31)
        ])
    end

    it "should work with byhour expansions" do
      schedule = IceCube::Schedule.from_ical "RRULE:FREQ=YEARLY;COUNT=2;BYMONTH=7;BYHOUR=1,2;BYSETPOS=1"
      schedule.start_time = Time.new(2016, 7, 5, 0, 0, 0)
      expect(schedule.occurrences_between(Time.new(2016, 01, 01), Time.new(2018, 01, 01))).
        to eq([
          Time.new(2016, 7, 5, 1, 0, 0),
          Time.new(2017, 7, 5, 1, 0, 0)
        ])
    end
  end
end
