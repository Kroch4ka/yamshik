# frozen_string_literal: true

RSpec.describe Yamshik do
  it "has a version number" do
    expect(Yamshik::VERSION).not_to be_nil
  end

  describe "configuration and carrier lookup" do
    let(:adapter_class) do
      Class.new do
        attr_reader :client_id, :sandbox

        def initialize(client_id: nil, sandbox: false)
          @client_id = client_id
          @sandbox = sandbox
        end
      end
    end

    before { described_class.register_adapter(:fake, adapter_class) }
    after { described_class.reset! }

    it "configures and instantiates a registered carrier with its config" do
      described_class.configure do |config|
        config.register :fake, client_id: "abc", sandbox: true
        config.default_timeout = 5
      end

      carrier = described_class.carrier(:fake)

      expect(carrier.client_id).to eq("abc")
      expect(carrier.sandbox).to be(true)
      expect(described_class.configuration.default_timeout).to eq(5)
    end

    it "instantiates a registered carrier with an empty config when not configured" do
      expect(described_class.carrier(:fake)).to be_a(adapter_class)
    end

    it "raises a helpful error for an unregistered carrier" do
      expect { described_class.carrier(:cdek) }
        .to raise_error(Yamshik::Error, /no adapter registered/)
    end

    it "memoizes the configuration" do
      expect(described_class.configuration).to equal(described_class.configuration)
    end
  end
end
