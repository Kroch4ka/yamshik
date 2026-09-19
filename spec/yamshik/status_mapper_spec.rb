# frozen_string_literal: true

RSpec.describe Yamshik::StatusMapper do
  subject(:mapper) do
    described_class.new(carrier: :cdek, mapping: { "ACCEPTED" => :created, "DELIVERED" => :delivered })
  end

  it "maps carrier codes to canonical statuses" do
    expect(mapper.map("ACCEPTED")).to eq(:created)
    expect(mapper.map("DELIVERED")).to eq(:delivered)
  end

  it "returns :unknown for unmapped codes" do
    expect(mapper.map("WEIRD_7")).to eq(:unknown)
  end

  it "triggers the on_unknown_status hook for unmapped codes" do
    received = nil
    Yamshik.configuration.on_unknown_status = ->(carrier:, carrier_code:) { received = [carrier, carrier_code] }

    mapper.map("WEIRD_7")

    expect(received).to eq([:cdek, "WEIRD_7"])
  ensure
    Yamshik.reset!
  end

  it "rejects mappings to non-canonical statuses" do
    expect { described_class.new(carrier: :cdek, mapping: { "X" => :teleported }) }
      .to raise_error(ArgumentError, /status mapping targets must be canonical/)
  end
end
