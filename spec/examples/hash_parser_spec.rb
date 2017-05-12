require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe HashParser do

    let(:t) { Time.utc(2014, 3, 22) }

    describe "#to_schedule" do
      subject(:schedule) { HashParser.new(hash).to_schedule }

      let(:hash) { {start_time: t, duration: 3600} }

      describe '#start_time' do
        subject { super().start_time }
        it { is_expected.to eq(t) }
      end

      describe '#duration' do
        subject { super().duration }
        it { is_expected.to eq(3600) }
      end

      describe "end_time overrules duration" do
        let(:hash) { {start_time: t, end_time: t + 1800, duration: 3600} }

        describe '#duration' do
          subject { super().duration }
          it { is_expected.to eq(1800) }
        end
      end

      describe "with an initial nil" do
        let(:hash) { nil }

        it 'has no recurrence rules' do
          schedule.recurrence_rules.should be_empty
        end

        it 'has no exception rules' do
          schedule.exception_rules.should be_empty
        end
      end
    end


  end
end
