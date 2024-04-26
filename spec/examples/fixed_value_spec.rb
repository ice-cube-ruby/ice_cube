require "spec_helper"

RSpec.describe IceCube::Validations::HourOfDay::Validation do

  describe :validate do
    let(:timezone) { "Africa/Cairo" }
    let(:time) { "2024-05-03 00:20:00" }
    let(:time_in_zone) { ActiveSupport::TimeZone[timezone].parse(time) }
    let(:start_time) { ActiveSupport::TimeZone[timezone].parse("2024-04-26 01:20:00") }

    let(:validation) { IceCube::Validations::HourOfDay::Validation.new(nil) }

    it "returns the correct offset for the same hour" do
      expect(validation.validate(time_in_zone, start_time)).to eq 1
    end
  end
end
