require File.dirname(__FILE__) + "/../spec_helper"

# This file is loaded and run alphabetically first in the suite, before
# ActiveSupport gets loaded by other specs.

module IceCube
  describe TimeUtil do
    before do
      raise "ActiveSupport should not be loaded" if defined?(ActiveSuppport)
    end

    WORLD_TIME_ZONES.each do |zone|
      context "in #{zone}", system_time_zone: zone do
        it "should be able to calculate end of dates without active_support" do
          date = Date.new(2011, 1, 1)
          end_of_date = Time.local(2011, 1, 1, 23, 59, 59)
          expect(TimeUtil.end_of_date(date).to_s).to eq(end_of_date.to_s)
        end

        it "should be able to calculate beginning of dates without active_support" do
          date = Date.new(2011, 1, 1)
          midnight = TimeUtil.beginning_of_date(date)

          expect(midnight).to eq(Time.local(2011, 1, 1, 0, 0, 0))
          expect(midnight).to be_a Time
        end

        it "should serialize to hash without error" do
          schedule = IceCube::Schedule.new(Time.now)
          schedule.add_recurrence_rule IceCube::Rule.hourly.until(Date.today >> 1)
          schedule.add_recurrence_time Time.now + 123
          schedule.add_exception_time Time.now + 456
          expect { schedule.to_hash }.to_not raise_error
        end
      end
    end
  end
end
