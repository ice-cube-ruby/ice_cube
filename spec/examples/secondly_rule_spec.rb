require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe SecondlyRule, 'interval validation' do
    it 'converts a string integer to an actual int when using the interval method' do
      rule = Rule.secondly.interval("2")
      expect(rule.validations_for(:interval).first.interval).to eq(2)
    end

    it 'converts a string integer to an actual int when using the initializer' do
      rule = Rule.secondly("3")
      expect(rule.validations_for(:interval).first.interval).to eq(3)
    end

    it 'raises an argument error when a bad value is passed' do
      expect {
        Rule.secondly("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
    end

    it 'raises an argument error when a bad value is passed using the interval method' do
      expect {
        Rule.secondly.interval("invalid")
      }.to raise_error(ArgumentError, "'invalid' is not a valid input for interval. Please pass a postive integer.")
    end

    it "should realign to the first second_of_minute" do
      t0 = Time.utc(2017, 1, 1, 20, 30, 40)
      schedule = IceCube::Schedule.new(t0)
      schedule.rrule IceCube::Rule.secondly(10).second_of_minute(5, 15)

      expect(schedule.first(3)).to eq [
        t0,
        t0 + 25*ONE_SECOND,
        t0 + 35*ONE_SECOND,
      ]
    end

    it "raises errors for misaligned interval and minute_of_hour values" do
      expect {
        IceCube::Rule.secondly(10).second_of_minute(3, 6)
      }.to raise_error(ArgumentError, "intervals in second_of_minute(3, 6) must be multiples of interval(10)")
    end

    it "raises errors for misaligned second_of_minute values when changing interval" do
      expect {
        IceCube::Rule.secondly(3).second_of_minute(3, 6).interval(5)
      }.to raise_error(ArgumentError, "interval(5) must be a multiple of intervals in second_of_minute(3, 6)")
    end

  end
end
