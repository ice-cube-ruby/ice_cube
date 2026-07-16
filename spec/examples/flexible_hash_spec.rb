require File.dirname(__FILE__) + "/../spec_helper"

module IceCube
  describe FlexibleHash do
    subject(:hash) { described_class.new(:sym => true, "str" => true, 1 => true) }

    describe "#[]" do
      specify ":sym => :sym is found" do
        expect(hash[:sym]).to be true
      end

      specify "'sym' => :sym is found" do
        expect(hash["sym"]).to be true
      end

      specify "'str' => 'str' is found" do
        expect(hash["str"]).to be true
      end

      specify ":str => 'str' is found" do
        expect(hash[:str]).to be true
      end

      specify "other types are found" do
        expect(hash[1]).to be true
      end

      specify "missing keys are nil" do
        expect(hash[-1]).to be nil
      end
    end

    describe "#fetch" do
      it "yields missing keys" do
        expect(hash.fetch(-1) { |k| k == -1 }).to be true
      end
    end

    describe "#delete" do
      specify ":sym => :sym is found and removed" do
        expect(hash.delete(:sym)).to be true
        expect(hash[:sym]).to be nil
      end

      specify "'sym' => :sym is found and removed" do
        expect(hash.delete("sym")).to be true
        expect(hash["sym"]).to be nil
      end

      specify "'str' => 'str' is found and removed" do
        expect(hash.delete("str")).to be true
        expect(hash["str"]).to be nil
      end

      specify ":str => 'str' is found and removed" do
        expect(hash.delete(:str)).to be true
        expect(hash[:str]).to be nil
      end

      specify "other types are found and removed" do
        expect(hash.delete(1)).to be true
        expect(hash[1]).to be nil
      end

      specify "missing keys are nil" do
        expect(hash.delete(-1)).to be nil
      end
    end
  end
end
