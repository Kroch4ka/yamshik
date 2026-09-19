# frozen_string_literal: true

RSpec.describe Yamshik::ParcelService do
  it "stores attributes" do
    service = described_class.new(kind: :insurance, carrier_code: "INSURANCE", amount: Yamshik::Money.new(amount: 5000))
    expect(service.kind).to eq(:insurance)
    expect(service.carrier_code).to eq("INSURANCE")
    expect(service.amount).to eq(Yamshik::Money.new(amount: 5000))
  end

  it "allows missing amount" do
    service = described_class.new(kind: :try_on, carrier_code: "TRY_ON")
    expect(service.amount).to be_nil
  end

  it "rejects unknown kinds" do
    expect { described_class.new(kind: :gift_wrap, carrier_code: "X") }.to raise_error(ArgumentError, /kind/)
  end

  it "accepts every canonical kind" do
    Yamshik::ParcelService::KINDS.each do |kind|
      expect(described_class.new(kind: kind, carrier_code: "X").kind).to eq(kind)
    end
  end
end
