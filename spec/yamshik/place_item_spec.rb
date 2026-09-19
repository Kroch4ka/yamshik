# frozen_string_literal: true

RSpec.describe Yamshik::PlaceItem do
  let(:item) { Yamshik::Item.new(name: "Футболка", quantity: 5, price: Yamshik::Money.new(amount: 10_000)) }

  it "stores item and quantity" do
    place_item = described_class.new(item: item, quantity: 2)
    expect(place_item.item).to eq(item)
    expect(place_item.quantity).to eq(2)
  end

  it "rejects non-positive quantity" do
    expect { described_class.new(item: item, quantity: 0) }.to raise_error(ArgumentError, /quantity/)
    expect { described_class.new(item: item, quantity: -1) }.to raise_error(ArgumentError, /quantity/)
  end
end
