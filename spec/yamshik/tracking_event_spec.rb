# frozen_string_literal: true

RSpec.describe Yamshik::TrackingEvent do
  let(:time) { Time.now }

  it "stores attributes" do
    event = described_class.new(status: :in_transit, carrier_code: "IN_TRANSIT", occurred_at: time, raw: { "a" => 1 })
    expect(event.status).to eq(:in_transit)
    expect(event.problem_kind).to be_nil
    expect(event.carrier_code).to eq("IN_TRANSIT")
    expect(event.occurred_at).to eq(time)
    expect(event.raw).to eq({ "a" => 1 })
  end

  it "rejects unknown statuses" do
    expect { described_class.new(status: :flying, carrier_code: "X", occurred_at: time) }
      .to raise_error(ArgumentError, /status/)
  end

  it "accepts problem_kind for problem status" do
    event = described_class.new(status: :problem, problem_kind: :damage, carrier_code: "DMG", occurred_at: time)
    expect(event.problem_kind).to eq(:damage)
  end

  it "rejects problem_kind for non-problem status" do
    expect do
      described_class.new(status: :in_transit, problem_kind: :damage, carrier_code: "X", occurred_at: time)
    end.to raise_error(ArgumentError, /problem_kind/)
  end

  it "rejects unknown problem kinds" do
    expect do
      described_class.new(status: :problem, problem_kind: :aliens, carrier_code: "X", occurred_at: time)
    end.to raise_error(ArgumentError, /problem_kind/)
  end
end
