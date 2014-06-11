require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe TimeUtil do

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

