require File.dirname(__FILE__) + "/../spec_helper"

describe Occurrence do
  it "reports as a Time" do
    occurrence = Occurrence.new(t0 = Time.now, t0 + 3600)
    expect(occurrence.class.name).to eq("Time")
    expect(occurrence.is_a?(Time)).to be_truthy
    expect(occurrence.is_a?(Time)).to be_truthy
  end

  describe :to_s do
    it "looks like a Time for a zero duration" do
      start_time = Time.now
      occurrence = Occurrence.new(start_time)

      expect(occurrence.to_s).to eq(start_time.to_s)
    end

    it "looks like a range for a non-zero duration" do
      start_time = Time.now
      end_time = start_time + ONE_HOUR
      occurrence = Occurrence.new(start_time, end_time)

      expect(occurrence.to_s).to eq("#{start_time} - #{end_time}")
    end

    it "accepts a format option to comply with ActiveSupport" do
      time_now = Time.current
      occurrence = Occurrence.new(time_now)

      # Match ActiveSupport formatting behavior across versions.
      expected =
        if time_now.respond_to?(:to_fs)
          time_now.to_fs(:short)
        elsif time_now.respond_to?(:to_formatted_s)
          time_now.to_formatted_s(:short)
        elsif time_now.public_method(:to_s).arity != 0
          time_now.to_s(:short)
        else
          time_now.to_s
        end

      expect(occurrence.to_s(:short)).to eq expected
    end
  end

  describe :to_i do
    it "represents the start time" do
      start_time = Time.now
      occurrence = Occurrence.new(start_time)

      expect(occurrence.to_i).to eq start_time.to_i
    end
  end

  describe :<=> do
    it "is comparable to another occurrence's start time" do
      o1 = Occurrence.new(Time.now)
      o2 = Occurrence.new(o1.start_time + 1)

      expect(o1).to be < o2
    end

    it "is comparable to another time" do
      occurrence = Occurrence.new(Time.now)
      expect(occurrence).to be < occurrence.start_time + 1
    end
  end

  describe :cover? do
    let(:start_time) { Time.now }
    let(:occurrence) { Occurrence.new(start_time, start_time + ONE_HOUR) }

    it "is true for the start time" do
      expect(occurrence.cover?(start_time)).to be true
    end

    it "is true for a time in the range" do
      expect(occurrence.cover?(start_time + 1)).to be true
    end

    it "is true for the end time" do
      expect(occurrence.cover?(start_time + ONE_HOUR)).to be true
    end

    it "is false after the end time" do
      expect(occurrence.cover?(start_time + ONE_HOUR + 1)).to be false
    end

    it "is false before the start time" do
      expect(occurrence.cover?(start_time - 1)).to be false
    end
  end

  describe :end_time do
    it "defaults to start_time" do
      start_time = Time.now
      occurrence = Occurrence.new(start_time)

      expect(occurrence.end_time).to eq(start_time)
    end

    it "returns specified end_time" do
      start_time = Time.now
      end_time = start_time + 3600
      occurrence = Occurrence.new(start_time, end_time)

      expect(occurrence.end_time).to eq(end_time)
    end
  end

  describe :arithmetic do
    let(:start_time) { Time.now }
    let(:occurrence) { Occurrence.new(start_time) }

    it "returns a time when adding" do
      new_time = occurrence + 60
      expect(new_time).to eq(start_time + 60)
    end

    it "can get difference from a time" do
      difference = occurrence - (start_time - 60)
      expect(difference).to eq(60)
    end
  end

  describe :intersects? do
    let(:start_time) { Time.now }
    let(:end_time) { start_time + 3600 }

    it "is true for a time during the occurrence" do
      occurrence = Occurrence.new(start_time, end_time)

      inclusion = occurrence.intersects? start_time + 1800
      expect(inclusion).to be_truthy
    end

    it "is false for a time outside the occurrence" do
      occurrence = Occurrence.new(start_time, end_time)

      inclusion = occurrence.intersects? start_time + 3601
      expect(inclusion).to be_falsey
    end

    it "is true for an intersecting occurrence" do
      occurrence1 = Occurrence.new(start_time, end_time)
      occurrence2 = Occurrence.new(start_time + 1, end_time + 1)

      inclusion = occurrence1.intersects? occurrence2
      expect(inclusion).to be_truthy
    end

    it "is false for a non-intersecting occurrence" do
      occurrence1 = Occurrence.new(start_time, end_time)
      occurrence2 = Occurrence.new(end_time)

      inclusion = occurrence1.intersects? occurrence2
      expect(inclusion).to be_falsey
    end
  end

  describe :overnight? do
    it "is false for a zero-length occurrence" do
      occurrence = Occurrence.new(Time.local(2013, 12, 24))
      expect(occurrence.overnight?).to be_falsey
    end

    it "is false for a zero-length occurrence on the last day of a month" do
      occurrence = Occurrence.new(Time.local(2013, 3, 31))
      expect(occurrence.overnight?).to be_falsey
    end

    it "is false for a duration within a single day" do
      t0 = Time.local(2013, 2, 24, 8, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3600)
      expect(occurrence.overnight?).to be_falsey
    end

    it "is false for a duration that starts at midnight" do
      t0 = Time.local(2013, 2, 24, 0, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3600)
      expect(occurrence.overnight?).to be_falsey
    end

    it "is false for a duration that starts at midnight on the last day of a month" do
      t0 = Time.local(2013, 3, 31, 0, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3600)
      expect(occurrence.overnight?).to be_falsey
    end

    it "is false for a duration that ends at midnight" do
      t0 = Time.local(2013, 2, 24, 23, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3600)
      expect(occurrence.overnight?).to be_falsey
    end

    it "is true for a duration that crosses midnight" do
      t0 = Time.local(2013, 2, 24, 23, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3601)
      expect(occurrence.overnight?).to be_truthy
    end

    it "is true for a duration that crosses midnight on the last day of a month" do
      t0 = Time.local(2013, 3, 31, 23, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3601)
      expect(occurrence.overnight?).to be_truthy
    end
  end
end
