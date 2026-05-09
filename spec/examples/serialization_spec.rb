require "active_support/time"
require File.dirname(__FILE__) + "/../spec_helper"

describe IceCube::Schedule do
  let(:start_time) { Time.now }
  let(:schedule) { IceCube::Schedule.new(start_time) }
  let(:yaml) { described_class.dump(schedule) }

  describe "::dump(schedule)" do
    it "serializes a Schedule object as YAML string" do
      expect(yaml).to start_with "---\n"
    end

    context "with ActiveSupport::TimeWithZone" do
      let(:start_time) { Time.now.in_time_zone("America/Vancouver") }

      it "serializes time as a Hash" do
        # Ruby 2.6-3.0 use positional args, Ruby 3.1+ uses keyword args for YAML.safe_load
        hash = if RUBY_VERSION < "3.1"
          YAML.safe_load(yaml, [Symbol, Time])
        else
          YAML.safe_load(yaml, permitted_classes: [Symbol, Time])
        end
        expect(hash[:start_time][:time]).to eq start_time.utc
        expect(hash[:start_time][:zone]).to eq "America/Vancouver"
      end
    end

    [nil, ""].each do |blank|
      context "when schedule is #{blank.inspect}" do
        let(:schedule) { blank }

        it "returns #{blank.inspect}" do
          expect(yaml).to be blank
        end
      end
    end
  end

  describe "::load(yaml)" do
    let(:new_schedule) { described_class.load yaml }

    it "creates a new object from a YAML string" do
      expect(new_schedule.start_time.to_s).to eq schedule.start_time.to_s
    end

    context "with ActiveSupport::TimeWithZone" do
      let(:start_time) { Time.now.in_time_zone("America/Vancouver") }

      it "deserializes time from Hash" do
        expect(new_schedule.start_time).to eq start_time
        expect(new_schedule.start_time.time_zone).to eq start_time.time_zone
      end
    end

    [nil, ""].each do |blank|
      context "when yaml is #{blank.inspect}" do
        let(:yaml) { blank }

        it "returns #{blank.inspect}" do
          expect(new_schedule).to be blank
        end
      end
    end
  end
end
