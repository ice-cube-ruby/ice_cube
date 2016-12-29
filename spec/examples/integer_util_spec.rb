require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe IntegerUtil do
    describe '.klass' do
      if RUBY_VERSION.include?("2.4")
        it 'is Integer' do
          expect(IntegerUtil.klass).to eq(Integer)
        end
      else
        it 'is Fixnum' do
          expect(IntegerUtil.klass).to eq(Fixnum)
        end
      end
    end
  end
end
