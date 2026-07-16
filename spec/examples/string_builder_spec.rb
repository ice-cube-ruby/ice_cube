require File.dirname(__FILE__) + "/../spec_helper"

describe IceCube::StringBuilder do
  describe :sentence do
    it "should return empty string when none" do
      expect(IceCube::StringBuilder.sentence([])).to eq("")
    end

    it "should return sole when one" do
      expect(IceCube::StringBuilder.sentence(["1"])).to eq("1")
    end

    it "should split on and when two" do
      expect(IceCube::StringBuilder.sentence(["1", "2"])).to eq("1 and 2")
    end

    it "should comma and when more than two" do
      expect(IceCube::StringBuilder.sentence(["1", "2", "3"])).to eq("1, 2, and 3")
    end
  end
end
