require File.dirname(__FILE__) + "/../spec_helper"

describe IceCube::StringBuilder do
  before :each do
    I18n.locale = :en
  end

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

  describe :nice_number do
    it "should return 1st for 1" do
      expect(IceCube::StringBuilder.nice_number(1)).to eq("1st")
    end

    it "should return 2nd for 2" do
      expect(IceCube::StringBuilder.nice_number(2)).to eq("2nd")
    end

    it "should return 3rd for 3" do
      expect(IceCube::StringBuilder.nice_number(3)).to eq("3rd")
    end

    it "should return last for -1" do
      expect(IceCube::StringBuilder.nice_number(-1)).to eq("last")
    end

    it "should return 2nd to last for -2" do
      expect(IceCube::StringBuilder.nice_number(-2)).to eq("2nd to last")
    end
  end
end
