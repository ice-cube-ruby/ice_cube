require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe HashParser do

    let(:t) { Time.utc(2014, 3, 22) }

    describe "#to_schedule" do
      subject(:schedule) { HashParser.new(hash).to_schedule }

      let(:hash) { {start_time: t, duration: 3600} }

      its(:start_time) { should == t }
      its(:duration)   { should == 3600 }

      describe "end_time overrules duration" do
        let(:hash) { {start_time: t, end_time: t + 1800, duration: 3600} }
        its(:duration) { should == 1800 }
      end
    end


  end
end

