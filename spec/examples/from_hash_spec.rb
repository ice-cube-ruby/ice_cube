require File.dirname(__FILE__) + "/../spec_helper"

module IceCube
  describe Rule, "from_hash" do
    describe "rule_type validations" do
      it "should raise an ArgumentError when the hash is empty" do
        expect { Rule.from_hash({}) }
          .to raise_error ArgumentError, "Invalid rule type"
      end

      it "should raise an ArgumentError when the hash[:rule_type] is invalid" do
        expect { Rule.from_hash({rule_type: "IceCube::MadeUpIntervalRule"}) }
          .to raise_error ArgumentError, "Invalid rule frequency type: MadeUpInterval"
      end

      it "returns a SecondlyRule when the hash[:rule_type] is secondly" do
        expect(Rule.from_hash({rule_type: "IceCube::SecondlyRule"})).to be_a SecondlyRule
      end

      it "returns a MinutelyRule when the hash[:rule_type] is minutely" do
        expect(Rule.from_hash({rule_type: "IceCube::MinutelyRule"})).to be_a MinutelyRule
      end

      it "returns a HourlyRule when the hash[:rule_type] is hourly" do
        expect(Rule.from_hash({rule_type: "IceCube::HourlyRule"})).to be_a HourlyRule
      end

      it "returns a DailyRule when the hash[:rule_type] is daily" do
        expect(Rule.from_hash({rule_type: "IceCube::DailyRule"})).to be_a DailyRule
      end

      it "returns a WeeklyRule when the hash[:rule_type] is weekly" do
        expect(Rule.from_hash({rule_type: "IceCube::WeeklyRule"})).to be_a WeeklyRule
      end

      it "returns a MonthlyRule when the hash[:rule_type] is monthly" do
        expect(Rule.from_hash({rule_type: "IceCube::MonthlyRule"})).to be_a MonthlyRule
      end

      it "returns a YearlyRule when the hash[:rule_type] is yearly" do
        expect(Rule.from_hash({rule_type: "IceCube::YearlyRule"})).to be_a YearlyRule
      end
    end

    describe "creating monthly rule" do
      context "with valid day_of_week validations" do
        let(:input_hash) {
          {
            rule_type: "IceCube::MonthlyRule",
            interval: 1,
            validations: {
              day_of_week: {
                "0": [2],
                "1": [2],
                "2": [2],
                "3": [2],
                "4": [2],
                "5": [2],
                "6": [1, 2]
              },
              hour_of_day: 7,
              minute_of_hour: 19
            }
          }
        }

        it "can provide the first occurrence" do
          rule = Rule.from_hash(input_hash)
          schedule = Schedule.new(Time.utc(2010, 1, 1, 0, 0, 0))
          schedule.add_recurrence_rule rule
          expect(schedule.first(10).map(&:to_time)).to eq([
            Time.utc(2010, 1, 2, 7, 19, 0),
            Time.utc(2010, 1, 8, 7, 19, 0),
            Time.utc(2010, 1, 9, 7, 19, 0),
            Time.utc(2010, 1, 10, 7, 19, 0),
            Time.utc(2010, 1, 11, 7, 19, 0),
            Time.utc(2010, 1, 12, 7, 19, 0),
            Time.utc(2010, 1, 13, 7, 19, 0),
            Time.utc(2010, 1, 14, 7, 19, 0),
            Time.utc(2010, 2, 6, 7, 19, 0),
            Time.utc(2010, 2, 8, 7, 19, 0)
          ])
        end
      end

      context "with invalid day_of_week validations" do
        let(:input_hash_with_zeroeth_occurrence) {
          {
            rule_type: "IceCube::MonthlyRule",
            interval: 1,
            validations: {
              day_of_week: {
                "1": [],
                "2": [0],
                "3": [],
                "4": []
              },
              hour_of_day: 7,
              minute_of_hour: 19
            }
          }
        }
        let(:input_hash_with_sixth_occurrence) {
          {
            rule_type: "IceCube::MonthlyRule",
            interval: 1,
            validations: {
              day_of_week: {
                "1": [],
                "2": [6],
                "3": [],
                "4": []
              },
              hour_of_day: 7,
              minute_of_hour: 19
            }
          }
        }

        it "should raise an ArgumentError" do
          expect { Rule.from_hash(input_hash_with_zeroeth_occurrence) }
            .to raise_error ArgumentError, "Invalid day_of_week occurrence: 0"
          expect { Rule.from_hash(input_hash_with_sixth_occurrence) }
            .to raise_error ArgumentError, "Invalid day_of_week occurrence: 6"
        end
      end
    end
  end
end
