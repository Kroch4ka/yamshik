# frozen_string_literal: true

RSpec.describe Yamshik::Adapters::Fake do
  subject(:fake) { described_class.new }

  let(:parcel) { build_valid_parcel(reference: "ORD-1") }

  it "is registered as :fake" do
    expect(Yamshik.carrier(:fake)).to be_a(described_class)
  end

  it "registers parcels with a generated external_id" do
    result = fake.create_order(parcel)

    expect(result.value.external_id).to eq("FAKE-1")
    expect(result.value.carrier).to eq(:fake)
    expect(result.value.registration_state).to eq(:registered)
  end

  it "is idempotent by reference" do
    first = fake.create_order(parcel).value
    second = fake.create_order(parcel).value

    expect(second.external_id).to eq(first.external_id)
  end
end
