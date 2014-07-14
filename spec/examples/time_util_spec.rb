require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe TimeUtil do

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
        expect(time.utc_offset).to eq (dst_time.utc_offset)
      end

      it "returns 00:00:00 from local time for UTC" do
        time = TimeUtil.beginning_of_date(dst_time.to_date, utc_time)
        expect([time.hour, time.min, time.sec]).to eq [0, 0, 0]
        expect(time.utc?).to eq true
      end

      it "returns 00:00:00 from local time for nonlocal time" do
        time = TimeUtil.beginning_of_date(dst_time.to_date, std_time.getlocal(7200))
        zone_diff = dst_time.utc_offset - 7200
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
        expect { TimeUtil.wday_to_sym(:anyday) }.to raise_error
        expect { TimeUtil.wday_to_sym(17) }.to raise_error
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
        expect { TimeUtil.sym_to_wday(:anyday) }.to raise_error
        expect { TimeUtil.sym_to_wday(17) }.to raise_error
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
        expect { TimeUtil.sym_to_month(13) }.to raise_error
        expect { TimeUtil.sym_to_month(:neveruary) }.to raise_error
      end
    end

    describe :deserialize_time do
      it 'supports ISO8601 time strings' do
        expect(TimeUtil.deserialize_time('2014-04-04T18:30:00+08:00')).to eq(Time.utc(2014, 4, 4, 10, 30, 0))
      end
    end

  end
end
