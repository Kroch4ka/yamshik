# frozen_string_literal: true

RSpec.describe Yamshik::Place do
  it "stores attributes and defaults collections to empty" do
    place = described_class.new(weight_g: 1000, length_cm: 30, width_cm: 20, height_cm: 10)
    expect(place.weight_g).to eq(1000)
    expect(place.length_cm).to eq(30)
    expect(place.place_items).to eq([])
    expect(place.labels).to eq([])
  end

  it "rejects non-positive weight_g" do
    expect { described_class.new(weight_g: 0) }.to raise_error(ArgumentError, /weight_g/)
    expect { described_class.new(weight_g: -5) }.to raise_error(ArgumentError, /weight_g/)
  end

  it "rejects non-positive dimensions when given" do
    expect { described_class.new(weight_g: 100, length_cm: 0) }.to raise_error(ArgumentError, /length_cm/)
    expect { described_class.new(weight_g: 100, width_cm: -1) }.to raise_error(ArgumentError, /width_cm/)
    expect { described_class.new(weight_g: 100, height_cm: 0) }.to raise_error(ArgumentError, /height_cm/)
  end

  it "allows missing dimensions" do
    place = described_class.new(weight_g: 100)
    expect(place.length_cm).to be_nil
    expect(place.width_cm).to be_nil
    expect(place.height_cm).to be_nil
  end
end
