require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe SecondlyRule, 'interval validation' do
    it 'converts a string integer to an actual int when using the interval method' do
      rule = Rule.secondly.interval("2")
      rule.validations_for(:interval).first.interval.should == 2
    end

    it 'converts a string integer to an actual int when using the initializer' do
      rule = Rule.secondly("3")
      rule.validations_for(:interval).first.interval.should == 3
    end

    it 'raises an argument error when a bad value is passed' do
      expect {
        rule = Rule.secondly("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass an integer.")
    end

    it 'raises an argument error when a bad value is passed using the interval method' do
      expect {
        rule = Rule.secondly.interval("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass an integer.")
    end
  end
end
