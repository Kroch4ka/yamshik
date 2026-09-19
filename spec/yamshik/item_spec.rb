# frozen_string_literal: true

RSpec.describe Yamshik::Item do
  let(:price) { Yamshik::Money.new(amount: 10_000) }

  it "stores attributes" do
    item = described_class.new(name: "Футболка", sku: "T-1", quantity: 2, price: price, weight_g: 250, vat_rate: 20)
    expect(item.name).to eq("Футболка")
    expect(item.sku).to eq("T-1")
    expect(item.quantity).to eq(2)
    expect(item.price).to eq(price)
    expect(item.weight_g).to eq(250)
    expect(item.vat_rate).to eq(20)
  end

  it "rejects zero quantity" do
    expect do
      described_class.new(name: "Футболка", quantity: 0, price: price)
    end.to raise_error(ArgumentError, /quantity/)
  end

  it "rejects negative quantity" do
    expect do
      described_class.new(name: "Футболка", quantity: -1, price: price)
    end.to raise_error(ArgumentError, /quantity/)
  end

  it "rejects non-positive weight_g" do
    expect do
      described_class.new(name: "Футболка", quantity: 1, price: price, weight_g: 0)
    end.to raise_error(ArgumentError, /weight_g/)
  end

  it "allows missing optional attributes" do
    item = described_class.new(name: "Футболка", quantity: 1, price: price)
    expect(item.sku).to be_nil
    expect(item.weight_g).to be_nil
    expect(item.vat_rate).to be_nil
  end
end
