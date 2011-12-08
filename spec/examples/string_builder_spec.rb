require File.dirname(__FILE__) + '/../spec_helper'

describe IceCube::StringBuilder do

  describe :sentence do

    it 'should return empty string when none' do
      IceCube::StringBuilder.sentence([]).should == ''
    end

    it 'should return sole when one' do
      IceCube::StringBuilder.sentence(['1']).should == '1'
    end

    it 'should split on and when two' do
      IceCube::StringBuilder.sentence(['1', '2']).should == '1 and 2'
    end

    it 'should comma and when more than two' do
      IceCube::StringBuilder.sentence(['1', '2', '3']).should == '1, 2, and 3'
    end

  end

end
