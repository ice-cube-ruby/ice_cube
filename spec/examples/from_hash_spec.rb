require File.dirname(__FILE__) + "/../spec_helper"

module IceCube
  describe Rule, "from_hash" do
    describe "rule_type validations" do
      it "should raise an ArgumentError when the hash is empty" do
        expect { Rule.from_hash({}) }
          .to raise_error ArgumentError, "Invalid rule type"
      end

      it "should raise an ArgumentError when the hash[:rule_type] is invalid" do
        expect { Rule.from_hash({ rule_type: "IceCube::MadeUpIntervalRule" }) }
          .to raise_error ArgumentError, "Invalid rule frequency type: MadeUpInterval"
      end

      it "returns a SecondlyRule when the hash[:rule_type] is secondly" do
        expect(Rule.from_hash({ rule_type: "IceCube::SecondlyRule" })).to be_a SecondlyRule
      end

      it "returns a MinutelyRule when the hash[:rule_type] is minutely" do
        expect(Rule.from_hash({ rule_type: "IceCube::MinutelyRule" })).to be_a MinutelyRule
      end

      it "returns a HourlyRule when the hash[:rule_type] is hourly" do
        expect(Rule.from_hash({ rule_type: "IceCube::HourlyRule" })).to be_a HourlyRule
      end

      it "returns a DailyRule when the hash[:rule_type] is daily" do
        expect(Rule.from_hash({ rule_type: "IceCube::DailyRule" })).to be_a DailyRule
      end

      it "returns a WeeklyRule when the hash[:rule_type] is weekly" do
        expect(Rule.from_hash({ rule_type: "IceCube::WeeklyRule" })).to be_a WeeklyRule
      end

      it "returns a MonthlyRule when the hash[:rule_type] is monthly" do
        expect(Rule.from_hash({ rule_type: "IceCube::MonthlyRule" })).to be_a MonthlyRule
      end

      it "returns a YearlyRule when the hash[:rule_type] is yearly" do
        expect(Rule.from_hash({ rule_type: "IceCube::YearlyRule" })).to be_a YearlyRule
      end
    end
  end
end
