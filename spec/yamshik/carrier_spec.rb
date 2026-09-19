# frozen_string_literal: true

RSpec.describe Yamshik::Carrier do
  subject(:adapter) { Class.new(described_class).new }

  describe "contract methods" do
    it "requires subclasses to implement #create_order" do
      expect { adapter.create_order(nil) }
        .to raise_error(NotImplementedError, /must implement #create_order/)
    end

    it "requires subclasses to implement #parcel" do
      expect { adapter.parcel("x") }
        .to raise_error(NotImplementedError, /must implement #parcel/)
    end
  end

  describe ".creation_strategy" do
    it "defaults to :unsafe" do
      expect(Class.new(described_class).creation_strategy).to eq(:unsafe)
    end

    it "accepts a known strategy" do
      klass = Class.new(described_class) { creation_strategy :idempotent }

      expect(klass.creation_strategy).to eq(:idempotent)
    end

    it "rejects unknown strategies" do
      expect { Class.new(described_class) { creation_strategy :yolo } }
        .to raise_error(ArgumentError, /creation_strategy must be one of/)
    end

    it "does not leak the declaration to sibling adapters" do
      Class.new(described_class) { creation_strategy :idempotent }

      expect(Class.new(described_class).creation_strategy).to eq(:unsafe)
    end
  end
end
