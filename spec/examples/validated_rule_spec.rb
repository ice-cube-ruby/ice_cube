require 'active_support/time'
require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube, "::ValidatedRule" do
  describe "#next_time" do
    context "monthly" do
      let(:rule) { IceCube::Rule.monthly }
      before { rule.reset }
      it "Should return current day when starting on same day" do
        first = Time.new(2013, 2, 25, 0, 0, 0)
        schedule = IceCube::Schedule.new(first)
        schedule.add_recurrence_rule rule
        rule.next_time(first, schedule, nil).should == first
      end

      it "Should return the next month when starting one second in the future" do
        first = Time.new(2013, 2, 25, 0, 0, 0)
        schedule = IceCube::Schedule.new(first)
        schedule.add_recurrence_rule rule
        rule.next_time(first + 1, schedule, nil).should == Time.new(2013, 3, 25, 0, 0, 0)
      end

      context "DST edge" do
        before { Time.zone = "Europe/London" }
        let(:first) { Time.zone.parse("Sun, 31 Mar 2013 00:00:00 GMT +00:00") }
        let(:schedule) {
          sc = IceCube::Schedule.new(first)
          sc.add_recurrence_rule rule
          sc
        }

        it "should not return the same time on a DST edge when starting one second in the future (results in infinite loop [#98])" do
          rule.next_time(first + 1, schedule, nil).to_s.should_not == first.to_s
        end

        it "previous failing test with DST edge taken into account" do
          rule.next_time(first + 1.hour + 1.second, schedule, nil).to_s.should_not == first.to_s
        end
      end
    end
  end
end
