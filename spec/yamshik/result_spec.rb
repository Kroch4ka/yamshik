# frozen_string_literal: true

RSpec.describe Yamshik::Result do
  let(:carrier_error) do
    Yamshik::CarrierError.new(code: :rejected, carrier: :cdek, message: "no")
  end

  describe ".ok" do
    subject(:result) { described_class.ok(42) }

    it "is a success carrying the value" do
      expect(result).to be_success
      expect(result).not_to be_failure
      expect(result.value).to eq(42)
    end

    it "raises on #error access" do
      expect { result.error }.to raise_error(RuntimeError, /cannot read #error/)
    end
  end

  describe ".err" do
    subject(:result) { described_class.err(carrier_error) }

    it "is a failure carrying the error" do
      expect(result).to be_failure
      expect(result).not_to be_success
      expect(result.error).to eq(carrier_error)
    end

    it "raises on #value access" do
      expect { result.value }.to raise_error(RuntimeError, /cannot read #value/)
    end

    it "requires a CarrierError" do
      expect { described_class.err(StandardError.new) }
        .to raise_error(ArgumentError, /expects a CarrierError/)
    end
  end

  it "cannot be instantiated directly" do
    expect { described_class.new(success: true) }.to raise_error(NoMethodError)
  end

  it "is frozen" do
    expect(described_class.ok(1)).to be_frozen
    expect(described_class.err(carrier_error)).to be_frozen
  end
end
