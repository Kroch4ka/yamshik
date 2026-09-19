# frozen_string_literal: true

RSpec.describe Yamshik::Contact do
  subject(:contact) do
    described_class.new(
      name: "Иван Иванов",
      phone: "+79001234567",
      company: Yamshik::Company.new(inn: "7707083893"),
      email: "ivan@example.com"
    )
  end

  it "stores attributes" do
    expect(contact.name).to eq("Иван Иванов")
    expect(contact.phone).to eq("+79001234567")
    expect(contact.company.inn).to eq("7707083893")
    expect(contact.email).to eq("ivan@example.com")
  end

  it "requires name" do
    expect { described_class.new(phone: "+79001234567") }.to raise_error(ArgumentError)
  end

  it "requires phone" do
    expect { described_class.new(name: "Иван Иванов") }.to raise_error(ArgumentError)
  end

  it "allows missing company and email" do
    minimal = described_class.new(name: "Иван Иванов", phone: "+79001234567")
    expect(minimal.company).to be_nil
    expect(minimal.email).to be_nil
  end

  it "is immutable and equal by value" do
    same = described_class.new(name: "Иван Иванов", phone: "+79001234567",
                               company: Yamshik::Company.new(inn: "7707083893"), email: "ivan@example.com")
    expect(contact).to eq(same)
    expect(contact.hash).to eq(same.hash)
    expect(contact).to be_frozen
  end
end
