require File.dirname(__FILE__) + '/../spec_helper'

include IceCube

describe Occurrence do

  it "reports as a Time" do
    occurrence = Occurrence.new(t0 = Time.now, t0 + 3600)
    occurrence.class.name.should == 'Time'
    occurrence.is_a?(Time).should be_true
    occurrence.kind_of?(Time).should be_true
  end

  describe :to_s do
    it "looks like a Time for a zero duration" do
      start_time = Time.now
      occurrence = Occurrence.new(start_time)

      occurrence.to_s.should == start_time.to_s
    end

    it "looks like a range for a non-zero duration" do
      start_time = Time.now
      end_time = start_time + ONE_HOUR
      occurrence = Occurrence.new(start_time, end_time)

      occurrence.to_s.should == "#{start_time} - #{end_time}"
    end

    it "accepts a format option to comply with ActiveSupport" do
      occurrence = Occurrence.new(Time.now)

      expect { occurrence.to_s(:short) }.not_to raise_error
    end
  end

  describe :end_time do

    it 'defaults to start_time' do
      start_time = Time.now
      occurrence = Occurrence.new(start_time)

      occurrence.end_time.should == start_time
    end

    it 'returns specified end_time' do
      start_time = Time.now
      end_time = start_time + 3600
      occurrence = Occurrence.new(start_time, end_time)

      occurrence.end_time.should == end_time
    end

  end

  describe :arithmetic do

    let(:start_time) { Time.now }
    let(:occurrence) { Occurrence.new(start_time) }

    it 'returns a time when adding' do
      new_time = occurrence + 60
      new_time.should == start_time + 60
    end

    it 'can get difference from a time' do
      difference = occurrence - (start_time - 60)
      difference.should == 60
    end

  end

  describe :intersects? do

    let(:start_time) { Time.now }
    let(:end_time)   { start_time + 3600 }

    it 'is true for a time during the occurrence' do
      occurrence = Occurrence.new(start_time, end_time)

      inclusion = occurrence.intersects? start_time + 1800
      inclusion.should be_true
    end

    it 'is false for a time outside the occurrence' do
      occurrence = Occurrence.new(start_time, end_time)

      inclusion = occurrence.intersects? start_time + 3601
      inclusion.should be_false
    end

    it 'is true for an intersecting occurrence' do
      occurrence1 = Occurrence.new(start_time, end_time)
      occurrence2 = Occurrence.new(start_time + 1, end_time + 1)

      inclusion = occurrence1.intersects? occurrence2
      inclusion.should be_true
    end

    it 'is false for a non-intersecting occurrence' do
      occurrence1 = Occurrence.new(start_time, end_time)
      occurrence2 = Occurrence.new(end_time)

      inclusion = occurrence1.intersects? occurrence2
      inclusion.should be_false
    end
  end

  describe :overnight? do
    it 'is false for a zero-length occurrence' do
      occurrence = Occurrence.new(Time.local(2013, 12, 24))
      occurrence.overnight?.should be_false
    end

    it 'is false for a duration within a single day' do
      t0 = Time.local(2013, 2, 24, 8, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3600)
      occurrence.overnight?.should be_false
    end

    it 'is false for a duration that starts at midnight' do
      t0 = Time.local(2013, 2, 24, 0, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3600)
      occurrence.overnight?.should be_false
    end

    it 'is false for a duration that ends at midnight' do
      t0 = Time.local(2013, 2, 24, 23, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3600)
      occurrence.overnight?.should be_false
    end

    it 'is true for a duration that crosses midnight' do
      t0 = Time.local(2013, 2, 24, 23, 0, 0)
      occurrence = Occurrence.new(t0, t0 + 3601)
      occurrence.overnight?.should be_true
    end
  end

end

