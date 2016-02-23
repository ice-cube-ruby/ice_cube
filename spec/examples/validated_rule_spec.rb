require 'active_support/time'
require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube, "::ValidatedRule" do
  describe "#next_time" do

    context "monthly" do
      let(:rule) { IceCube::Rule.monthly }

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

      it 'should return the next month near end of longer month [#171]' do
        schedule = IceCube::Schedule.new(Date.new 2013, 1, 1)
        [27, 28, 29, 30, 31].each do |day|
          rule.next_time(Time.new(2013, 1, day), schedule, nil).should == Time.new(2013, 2, 1)
        end
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

    it 'should match times with usec' do
      first_time = Time.new(2012, 12, 21, 12, 21, 12.12121212)
      schedule = double(:start_time => first_time)
      rule = IceCube::Rule.secondly

      rule.next_time(first_time + 1, schedule, nil).should == first_time + 1
    end
  end

  describe "duration validation" do
    let(:rule) { IceCube::Rule.monthly }

    it "should respond to :override_duration" do
      rule.respond_to?(:override_duration).should == true
    end

    describe "#duration" do
      it "should return nil if if no duration validation set" do
        rule.duration.should == nil
      end

      it "should return the duration set with validation" do
        rule.override_duration(IceCube::ONE_DAY).duration.should == IceCube::ONE_DAY
      end
    end

    describe "#overrides_duration?" do
      it "should return true with duration validation" do
        rule.override_duration(IceCube::ONE_DAY).overrides_duration?.should == true
      end

      it "should return false if no duration validation set" do
        rule.overrides_duration?.should == false
      end
    end

    it "should not affect string builder" do
      rule.to_s.should == rule.override_duration(IceCube::ONE_DAY).to_s
    end

    it "should export :duration to hash" do
      rule.to_hash.should_not have_key :duration
      rule.override_duration(IceCube::ONE_DAY).to_hash[:duration].should == IceCube::ONE_DAY
    end

    it "should not export duration to ICAL" do
      rule.to_ical.should == rule.override_duration(IceCube::ONE_DAY).to_ical
    end
  end



end
