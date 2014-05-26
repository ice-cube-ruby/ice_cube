require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe SecondlyRule, 'interval validation' do
    it 'converts a string integer to an actual int' do
      rule = Rule.secondly("1")
      rule.instance_variable_get(:@interval).should == 1
    end

    it 'raises an argument error when a bad value is passed' do
      expect {
        rule = Rule.secondly("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass an integer.")
    end
  end
end
