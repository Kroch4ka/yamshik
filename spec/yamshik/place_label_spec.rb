# frozen_string_literal: true

RSpec.describe Yamshik::PlaceLabel do
  it "stores content labels" do
    label = described_class.new(format: :pdf, content: "%PDF-binary")
    expect(label.format).to eq(:pdf)
    expect(label.content).to eq("%PDF-binary")
    expect(label.url).to be_nil
  end

  it "stores url labels" do
    label = described_class.new(format: :png, url: "https://example.com/label.png")
    expect(label.url).to eq("https://example.com/label.png")
  end

  it "rejects unknown formats" do
    expect { described_class.new(format: :docx, content: "x") }.to raise_error(ArgumentError, /format/)
  end

  it "requires content or url" do
    expect { described_class.new(format: :pdf) }.to raise_error(ArgumentError, /content or url/)
  end
end
