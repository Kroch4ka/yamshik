# frozen_string_literal: true

RSpec.describe Yamshik::Point do
  it "defaults country_code to RU" do
    expect(described_class.new(city: "Москва").country_code).to eq("RU")
  end

  it "requires city" do
    expect { described_class.new(address: "ул. Ленина, 1") }.to raise_error(ArgumentError)
  end

  describe "#type" do
    it "is :door without a pickup point code" do
      point = described_class.new(city: "Москва", address: "ул. Ленина, 1")
      expect(point.type).to eq(:door)
    end

    it "is :pickup_point with a pickup point code" do
      point = described_class.new(city: "Москва", pickup_point_code: "MSK1")
      expect(point.type).to eq(:pickup_point)
    end
  end
end
