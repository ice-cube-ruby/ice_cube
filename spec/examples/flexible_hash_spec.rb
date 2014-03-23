require File.dirname(__FILE__) + '/../spec_helper'

module IceCube
  describe FlexibleHash do

    subject(:hash) { described_class.new(:sym => true, "str" => true, 1 => true) }

    describe "#[]" do
      specify ":sym => :sym is found" do
        hash[:sym].should be true
      end

      specify "'sym' => :sym is found" do
        hash["sym"].should be true
      end

      specify "'str' => 'str' is found" do
        hash["str"].should be true
      end

      specify ":str => 'str' is found" do
        hash[:str].should be true
      end

      specify "other types are found" do
        hash[1].should be true
      end

      specify "missing keys are nil" do
        hash[-1].should be nil
      end
    end

    describe "#fetch" do
      it "yields missing keys" do
        hash.fetch(-1) { |k| k == -1 }.should be true
      end
    end

    describe "#delete" do
      specify ":sym => :sym is found and removed" do
        hash.delete(:sym).should be true
        hash[:sym].should be nil
      end

      specify "'sym' => :sym is found and removed" do
        hash.delete("sym").should be true
        hash["sym"].should be nil
      end

      specify "'str' => 'str' is found and removed" do
        hash.delete("str").should be true
        hash["str"].should be nil
      end

      specify ":str => 'str' is found and removed" do
        hash.delete(:str).should be true
        hash[:str].should be nil
      end

      specify "other types are found and removed" do
        hash.delete(1).should be true
        hash[1].should be nil
      end

      specify "missing keys are nil" do
        hash.delete(-1).should be nil
      end
    end

  end
end
