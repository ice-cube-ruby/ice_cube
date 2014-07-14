require 'active_support/time'
require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::Schedule do

  let(:schedule) { IceCube::Schedule.new Time.now }
  let(:yaml)     { described_class.dump(schedule) }

  describe "::dump(schedule)" do

    it "serializes a Schedule object as YAML string" do
      expect(yaml).to start_with "---\n"
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
