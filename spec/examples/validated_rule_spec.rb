require "active_support/time"
require File.dirname(__FILE__) + "/../spec_helper"

describe IceCube, "::ValidatedRule" do
  describe "#next_time" do
    context "monthly" do
      let(:rule) { IceCube::Rule.monthly }

      it "Should return current day when starting on same day" do
        t0 = Time.new(2013, 2, 25, 0, 0, 0)
        expect(rule.next_time(t0, t0, nil)).to eq(t0)
      end

      it "Should return the next month when starting one second in the future" do
        t0 = Time.new(2013, 2, 25, 0, 0, 0)
        t1 = Time.new(2013, 3, 25, 0, 0, 0)
        expect(rule.next_time(t0 + 1, t0, nil)).to eq t1
      end

      it "should return the next month near end of longer month [#171]" do
        t0 = Time.new(2013, 1, 1)
        t1 = Time.new(2013, 2, 1)
        [27, 28, 29, 30, 31].each do |day|
          expect(rule.next_time(Time.new(2013, 1, day), t0, nil)).to eq t1
        end
      end

      context "DST edge", system_time_zone: "Europe/London" do
        let(:t0) { Time.local(2013, 3, 31) }

        it "should not return the same time on a DST edge when starting one second in the future (results in infinite loop [#98])" do
          expect(rule.next_time(t0 + 1, t0, nil)).to eq Time.local(2013, 4, 30)
        end

        it "previous failing test with DST edge taken into account" do
          expect(rule.next_time(t0 + ONE_HOUR + 1, t0, nil)).to eq Time.local(2013, 4, 30)
        end
      end
    end

    it "should match times with usec" do
      t0 = Time.new(2012, 12, 21, 12, 21, 12.12121212)
      rule = IceCube::Rule.secondly

      expect(rule.next_time(t0 + 1, t0, nil)).to eq(t0 + 1)
    end
  end
end
