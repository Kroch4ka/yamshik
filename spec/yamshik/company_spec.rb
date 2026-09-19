# frozen_string_literal: true

RSpec.describe Yamshik::Company do
  it "stores inn" do
    expect(described_class.new(inn: "7707083893").inn).to eq("7707083893")
  end
end
