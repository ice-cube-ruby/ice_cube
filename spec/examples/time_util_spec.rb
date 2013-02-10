require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe TimeUtil do

    describe :wday_to_sym do
      it 'converts 0..6 to weekday symbols' do
        TimeUtil.wday_to_sym(1).should == :monday
      end

      it 'returns weekday symbols as is' do
        TimeUtil.wday_to_sym(:monday).should == :monday
      end

      it 'raises an error for bad input' do
        expect { TimeUtil.wday_to_sym(:anyday) }.to raise_error
        expect { TimeUtil.wday_to_sym(17) }.to raise_error
      end
    end

    describe :sym_to_wday do
      it 'converts weekday symbols to 0..6 wday numbers' do
        TimeUtil.sym_to_wday(:monday).should == 1

      end

      it 'returns wday numbers as is' do
        TimeUtil.sym_to_wday(1).should == 1
      end

      it 'raises an error for bad input' do
        expect { TimeUtil.sym_to_wday(:anyday) }.to raise_error
        expect { TimeUtil.sym_to_wday(17) }.to raise_error
      end
    end

    describe :sym_to_month do
      it 'converts month symbols to 1..12 month numbers' do
        TimeUtil.sym_to_month(:january).should == 1
      end

      it 'returns month numbers as is' do
        TimeUtil.sym_to_month(12).should == 12
      end

      it 'raises an error for bad input' do
        expect { TimeUtil.sym_to_month(13) }.to raise_error
        expect { TimeUtil.sym_to_month(:neveruary) }.to raise_error
      end
    end

  end
end

