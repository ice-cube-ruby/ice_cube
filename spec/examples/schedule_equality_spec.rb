require "spec_helper"

module IceCube
  describe Schedule do
    let(:t0) { Time.utc(2017, 1, 1, 12, 34, 56) }
    let(:s1) { IceCube::Schedule.new(t0) }
    let(:s2) { IceCube::Schedule.new(t0) }

    describe :eql? do
      subject(:equality) { s1 == s2 }

      it "should be true for same start time" do
        should be true
      end

      it "should be false for different start time" do
        s2.start_time = t0 + 1
        should be false
      end

      it "should be false for UTC vs. British start time", system_time_zone: "Europe/London" do
        s2.start_time = t0.getlocal
        should be false
      end

      it "should be false with different offset" do
        s1.start_time = s1.start_time.getlocal("-06:00")
        s2.start_time = s1.start_time.getlocal("-05:00")
        should be false
      end

      it "should be true with same static offset" do
        s1.start_time = t0.getlocal("-08:00")
        s2.start_time = t0.getlocal("-08:00")
        should be true
      end

      it "should be false with local zone vs. static offset", system_time_zone: "America/Vancouver" do
        s1.start_time = t0.getlocal
        s2.start_time = t0.getlocal(s1.start_time.utc_offset)
        should be false
      end

      it "should be false with different duration" do
        s2.duration = ONE_HOUR
        should be false
      end

      it "should be false with different end time" do
        s2.end_time = s2.start_time + ONE_HOUR
        should be false
      end

      context "with ActiveSupport", requires_active_support: true do
        require "active_support/time"
        let(:utc_tz) { ActiveSupport::TimeZone["Etc/UTC"] }
        let(:pst_tz) { ActiveSupport::TimeZone["America/Vancouver"] }
        let(:est_tz) { ActiveSupport::TimeZone["America/New_York"] }
        let(:activesupport_t0) { utc_tz.local(2017, 1, 1, 12, 34, 56) }

        it "should be true for ActiveSupport UTC vs. standard UTC" do
          s2.start_time = activesupport_t0
          should be true
        end

        it "should be true for ActiveSupport TZ vs. standard TZ", system_time_zone: "America/Vancouver" do
          s1.start_time = t0.getlocal
          s2.start_time = activesupport_t0.in_time_zone(pst_tz)
          should be true
        end

        it "should be false for different ActiveSupport zones" do
          s2.start_time = activesupport_t0.in_time_zone(pst_tz)
          s1.start_time = activesupport_t0.in_time_zone(est_tz)
          should be false
        end
      end

      it "should be true with same rrules in different order" do
        s1.rrule Rule.weekly.day(:thursday)
        s1.rrule Rule.monthly.day_of_month(1)
        s2.rrule Rule.monthly.day_of_month(1)
        s2.rrule Rule.weekly.day(:thursday)
        should be true
      end

      it "should be false with different rrules" do
        s1.rrule Rule.weekly
        s2.rrule Rule.weekly(2)
        should be false
      end

      it "should be true with same extimes in different order" do
        s1.rrule Rule.hourly
        s1.extime t0 + ONE_HOUR
        s1.extime t0 + 3 * ONE_HOUR
        s2.rrule Rule.hourly
        s2.extime t0 + 3 * ONE_HOUR
        s2.extime t0 + ONE_HOUR
        should be true
      end

      it "should be false with different extimes" do
        s1.rrule Rule.hourly
        s1.extime t0 + ONE_HOUR
        s1.rrule Rule.hourly
        s2.extime t0 + 3 * ONE_HOUR
        should be false
      end
    end
  end
end
