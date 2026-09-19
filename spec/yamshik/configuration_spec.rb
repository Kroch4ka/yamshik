# frozen_string_literal: true

RSpec.describe Yamshik::Configuration do
  subject(:config) { described_class.new }

  describe "#register / #carrier_config" do
    it "stores per-carrier config keyed by symbol" do
      config.register(:cdek, client_id: "id", client_secret: "secret")

      expect(config.carrier_config(:cdek)).to eq(client_id: "id", client_secret: "secret")
    end

    it "normalizes string names to symbols" do
      config.register("cdek", client_id: "id")

      expect(config.carrier_config(:cdek)).to eq(client_id: "id")
    end

    it "returns an empty hash for unregistered carriers" do
      expect(config.carrier_config(:boxberry)).to eq({})
    end
  end

  describe "defaults" do
    it "has a default timeout of 10 seconds" do
      expect(config.default_timeout).to eq(10)
    end

    it "has no logger and no on_unknown_status hook by default" do
      expect(config.logger).to be_nil
      expect(config.on_unknown_status).to be_nil
    end
  end

  describe "on_unknown_status hook" do
    it "accepts a callable" do
      received = nil
      config.on_unknown_status = ->(carrier:, carrier_code:) { received = [carrier, carrier_code] }
      config.on_unknown_status.call(carrier: :cdek, carrier_code: "WEIRD_7")

      expect(received).to eq([:cdek, "WEIRD_7"])
    end
  end
end
