# frozen_string_literal: true

RSpec.describe Yamshik::Money do
  subject(:money) { described_class.new(amount: 1500, currency: "RUB") }

  it "defaults currency to RUB" do
    expect(described_class.new(amount: 100).currency).to eq("RUB")
  end

  it "rejects non-integer amounts" do
    expect { described_class.new(amount: 15.5) }.to raise_error(ArgumentError, /amount/)
  end

  describe "equality" do
    it "equals money with the same amount and currency" do
      expect(money).to eq(described_class.new(amount: 1500, currency: "RUB"))
      expect(money.eql?(described_class.new(amount: 1500, currency: "RUB"))).to be(true)
      expect(money.hash).to eq(described_class.new(amount: 1500, currency: "RUB").hash)
    end

    it "differs by amount" do
      expect(money).not_to eq(described_class.new(amount: 1501))
    end

    it "differs by currency" do
      expect(money).not_to eq(described_class.new(amount: 1500, currency: "USD"))
    end

    it "differs from non-money objects" do
      expect(money).not_to eq(1500)
    end
  end

  describe "#+" do
    it "adds amounts of the same currency" do
      sum = money + described_class.new(amount: 500)
      expect(sum).to eq(described_class.new(amount: 2000, currency: "RUB"))
    end

    it "rejects different currencies" do
      expect { money + described_class.new(amount: 500, currency: "USD") }.to raise_error(ArgumentError, /cannot add/)
    end

    it "rejects non-money operands" do
      expect { money + 500 }.to raise_error(ArgumentError)
    end
  end
end
