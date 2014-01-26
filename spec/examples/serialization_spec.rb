require 'active_support/time'
require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::Schedule do
  let(:schedule) { IceCube::Schedule.new Time.now }
  let(:yaml)     { described_class.dump(schedule) }

  describe '::dump(schedule)' do
    it 'serializes a Schedule object as YAML string' do
      yaml.should be_a_kind_of String
    end
  end

  describe '::load(yaml)' do
    let(:new_schedule) { described_class.load yaml }

    it 'creates a new object from a YAML string' do
      new_schedule.start_time.to_s.should eq schedule.start_time.to_s
    end

    context 'when yaml is blank' do
      let(:yaml) { nil }

      it 'returns nil' do
        new_schedule.should be_nil
      end
    end
  end
end

