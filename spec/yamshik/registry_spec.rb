# frozen_string_literal: true

RSpec.describe Yamshik::Registry do
  after { described_class.reset! }

  let(:adapter_class) { Class.new }

  describe ".register / .registered?" do
    it "registers an adapter class under a carrier name" do
      described_class.register(:cdek, adapter_class)

      expect(described_class.registered?(:cdek)).to be(true)
      expect(described_class.registered?(:boxberry)).to be(false)
    end

    it "normalizes string names to symbols" do
      described_class.register("cdek", adapter_class)

      expect(described_class.registered?(:cdek)).to be(true)
    end
  end

  describe ".fetch" do
    it "returns the registered adapter class" do
      described_class.register(:cdek, adapter_class)

      expect(described_class.fetch(:cdek)).to eq(adapter_class)
    end

    it "raises a helpful error for unknown carriers" do
      expect { described_class.fetch(:cdek) }
        .to raise_error(Yamshik::Error, %r{no adapter registered.*:cdek.*require "yamshik/cdek"})
    end
  end
end
