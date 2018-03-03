require File.dirname(__FILE__) + '/../spec_helper'
require 'active_support/time'

module IceCube
  describe TimeUtil do

    describe :build_in_zone do

      around :each do |example|
        Time.zone = 'Pacific Time (US & Canada)'
        example.run
        Time.zone = nil
      end

      let(:utc_time)    { Time.utc(2018, 3, 3, 2, 25, 47) }
      let(:local_time)  { Time.zone.local(2018, 3, 3, 2, 25, 47) }
      let(:offset_time) { Time.new(2018, 3, 3, 2, 25, 47, '+02:00') }
      let(:test_time)   { [2018, 3, 3, 7, 36, 25] }
      let(:test_date)   { [2018, 3, 21] }

      it "returns the test time in UTC when reference is utc" do
        expect(TimeUtil.build_in_zone(test_time, utc_time)).to eq Time.utc(*test_time)
      end

      it "returns the time in reference time zone if not utc" do
        expect(TimeUtil.build_in_zone(test_time, local_time)).to eq local_time.time_zone.local(*test_time)
      end

      it "returns the time with correct offset for offset reference" do
        expect(TimeUtil.build_in_zone(test_time, offset_time).utc_offset).to eq offset_time.utc_offset
      end

      it "returns the current date start in utc for utc reference" do
        expect(TimeUtil.build_in_zone(test_date, utc_time)).to eq Time.utc(*test_date)
      end

      it "returns the current date start in reference time zone for non-utc reference" do
        expect(TimeUtil.build_in_zone(test_date, local_time)).to eq local_time.time_zone.local(*test_date)
      end

      it "retunrs the current date with correct utc offset for non-utc reference" do
        expect(TimeUtil.build_in_zone(test_date, offset_time)).to eq Time.new(*test_date, 0, 0, 0, offset_time.utc_offset)
      end
    end

    describe :beginning_of_date do

      let(:utc_time) { Time.utc(2014, 7, 8, 12, 34, 56) }
      let(:dst_time) { Time.local(2014, 7, 8, 12, 34, 56) }
      let(:std_time) { Time.local(2014, 1, 1, 12, 34, 56) }

      it "returns 00:00:00 crossing into DST" do
        time = TimeUtil.beginning_of_date(dst_time.to_date, std_time)
        dst_diff = dst_time.utc_offset - std_time.utc_offset
        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc_offset - std_time.utc_offset).to eq dst_diff
      end

      it "returns 00:00:00 crossing out of DST" do
        time = TimeUtil.beginning_of_date(std_time.to_date, dst_time)
        dst_diff = std_time.utc_offset - dst_time.utc_offset
        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc_offset - dst_time.utc_offset).to eq dst_diff
      end

      it "returns 00:00:00 from UTC for local time" do
        time = TimeUtil.beginning_of_date(utc_time.to_date, dst_time)
        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc_offset).to eq dst_time.utc_offset
      end

      it "returns 00:00:00 from local time for UTC" do
        time = TimeUtil.beginning_of_date(dst_time.to_date, utc_time)
        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc?).to eq true
      end

      it "returns 00:00:00 from local time for nonlocal time" do
        time = TimeUtil.beginning_of_date(dst_time.to_date, std_time.getlocal(7200))

        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc_offset).to eq 7200
      end

    end

    describe :wday_to_sym do
      it 'converts 0..6 to weekday symbols' do
        expect(TimeUtil.wday_to_sym(1)).to eq(:monday)
      end

      it 'returns weekday symbols as is' do
        expect(TimeUtil.wday_to_sym(:monday)).to eq(:monday)
      end

      it 'raises an error for bad input' do
        expect { TimeUtil.wday_to_sym(:anyday) }.to raise_error(ArgumentError)
        expect { TimeUtil.wday_to_sym(17) }.to raise_error(ArgumentError)
      end
    end

    describe :sym_to_wday do
      it 'converts weekday symbols to 0..6 wday numbers' do
        expect(TimeUtil.sym_to_wday(:monday)).to eq(1)

      end

      it 'returns wday numbers as is' do
        expect(TimeUtil.sym_to_wday(1)).to eq(1)
      end

      it 'raises an error for bad input' do
        expect { TimeUtil.sym_to_wday(:anyday) }.to raise_error(ArgumentError)
        expect { TimeUtil.sym_to_wday(17) }.to raise_error(ArgumentError)
      end
    end

    describe :sym_to_month do
      it 'converts month symbols to 1..12 month numbers' do
        expect(TimeUtil.sym_to_month(:january)).to eq(1)
      end

      it 'returns month numbers as is' do
        expect(TimeUtil.sym_to_month(12)).to eq(12)
      end

      it 'raises an error for bad input' do
        expect { TimeUtil.sym_to_month(13) }.to raise_error(ArgumentError)
        expect { TimeUtil.sym_to_month(:neveruary) }.to raise_error(ArgumentError)
      end
    end

    describe :deserialize_time do
      it 'supports ISO8601 time strings' do
        expect(TimeUtil.deserialize_time('2014-04-04T18:30:00+08:00')).to eq(Time.utc(2014, 4, 4, 10, 30, 0))
      end
    end

    describe :match_zone do

      let(:date) { Date.new(2014, 1, 1) }

      WORLD_TIME_ZONES.each do |zone|
        context "in #{zone}", :system_time_zone => zone do
          let(:utc_time)   { Time.utc(2014, 1, 1, 0, 0, 1) }
          let(:local_time) { Time.local(2014, 1, 1, 0, 0, 1) }

          it 'converts Date to beginning of date of local reference time' do
            expect(TimeUtil.match_zone(date, local_time)).to eq local_time - 1
          end

          it 'converts Date to beginning of date of UTC reference time' do
            expect(TimeUtil.match_zone(date, utc_time)).to eq utc_time - 1
          end
        end
      end

      context "in UTC" do
        let(:utc_time) { Time.utc(2014, 1, 1, 0, 0, 1) }

        it 'converts Date to beginning of date of reference time' do
          expect(TimeUtil.match_zone(date, utc_time)).to eq utc_time - 1
        end
      end
    end

  end
end
