# frozen_string_literal: true

RSpec.describe Yamshik::CarrierError do
  subject(:error) do
    described_class.new(code: :validation_failed, carrier: :cdek, message: "weight is required")
  end

  it "is a data object, not an exception" do
    expect(described_class.ancestors).not_to include(StandardError)
  end

  it "exposes code, carrier and message" do
    expect(error.code).to eq(:validation_failed)
    expect(error.carrier).to eq(:cdek)
    expect(error.message).to eq("weight is required")
  end

  it "defaults details, raw and carrier_code to nil" do
    expect(error.details).to be_nil
    expect(error.raw).to be_nil
    expect(error.carrier_code).to be_nil
  end

  it "accepts optional fields" do
    error = described_class.new(
      code: :not_found, carrier: :cdek, message: "no such order",
      details: { path: "reference" }, raw: { "code" => "ERR_1" }, carrier_code: "ERR_1"
    )

    expect(error.details).to eq(path: "reference")
    expect(error.carrier_code).to eq("ERR_1")
  end

  it "rejects codes outside the canonical taxonomy" do
    expect { described_class.new(code: :boom, carrier: :cdek, message: "x") }
      .to raise_error(ArgumentError, /code must be one of/)
  end

  it "accepts every code from the taxonomy" do
    described_class::CODES.each do |code|
      expect { described_class.new(code:, carrier: :cdek, message: "x") }.not_to raise_error
    end
  end

  it "requires carrier to be a Symbol" do
    expect { described_class.new(code: :rejected, carrier: "cdek", message: "x") }
      .to raise_error(ArgumentError, /carrier must be a Symbol/)
  end

  it "requires message to be a String" do
    expect { described_class.new(code: :rejected, carrier: :cdek, message: nil) }
      .to raise_error(ArgumentError, /message must be a String/)
  end

  it "is immutable and comparable by value" do
    same = described_class.new(code: :validation_failed, carrier: :cdek, message: "weight is required")

    expect(error).to eq(same)
    expect(error).to be_frozen
  end
end
