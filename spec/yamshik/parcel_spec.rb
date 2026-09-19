# frozen_string_literal: true

RSpec.describe Yamshik::Parcel do
  let(:sender) { Yamshik::Contact.new(name: "Отправитель", phone: "+79001111111") }
  let(:recipient) { Yamshik::Contact.new(name: "Получатель", phone: "+79002222222") }
  let(:origin) { Yamshik::Point.new(city: "Москва", address: "ул. Ленина, 1") }
  let(:destination) { Yamshik::Point.new(city: "Казань", pickup_point_code: "KZN1") }
  let(:item) { Yamshik::Item.new(name: "Футболка", quantity: 3, price: Yamshik::Money.new(amount: 10_000)) }

  def build_parcel(**overrides)
    described_class.new(reference: "order-1", sender: sender, recipient: recipient,
                        origin: origin, destination: destination, **overrides)
  end

  it "stores required attributes" do
    parcel = build_parcel
    expect(parcel.reference).to eq("order-1")
    expect(parcel.sender).to eq(sender)
    expect(parcel.recipient).to eq(recipient)
    expect(parcel.origin).to eq(origin)
    expect(parcel.destination).to eq(destination)
  end

  it "defaults optional attributes" do
    parcel = build_parcel
    expect(parcel.external_id).to be_nil
    expect(parcel.carrier).to be_nil
    expect(parcel.comment).to be_nil
  end

  it "defaults collections and registration state" do
    parcel = build_parcel
    expect(parcel.registration_state).to eq(:pending)
    expect(parcel.items).to eq([])
    expect(parcel.places).to eq([])
    expect(parcel.services).to eq([])
  end

  it "freezes itself and its collections" do
    parcel = build_parcel(items: [item], places: [Yamshik::Place.new(weight_g: 100)])
    expect(parcel).to be_frozen
    expect(parcel.items).to be_frozen
    expect(parcel.places).to be_frozen
    expect(parcel.services).to be_frozen
  end

  it "requires reference, sender, recipient, origin and destination" do
    expect { build_parcel(reference: nil) }.to raise_error(ArgumentError, /reference/)
    expect { build_parcel(sender: nil) }.to raise_error(ArgumentError, /sender/)
    expect { described_class.new(sender: sender, recipient: recipient, origin: origin, destination: destination) }
      .to raise_error(ArgumentError)
  end

  it "rejects unknown registration_state" do
    expect { build_parcel(registration_state: :lost) }.to raise_error(ArgumentError, /registration_state/)
  end

  it "accepts every registration state" do
    Yamshik::Parcel::REGISTRATION_STATES.each do |state|
      expect(build_parcel(registration_state: state).registration_state).to eq(state)
    end
  end

  describe "#delivery_type" do
    it "is :pickup_point when destination has a pickup point code" do
      expect(build_parcel.delivery_type).to eq(:pickup_point)
    end

    it "is :door when destination has no pickup point code" do
      parcel = build_parcel(destination: Yamshik::Point.new(city: "Казань", address: "ул. Баумана, 1"))
      expect(parcel.delivery_type).to eq(:door)
    end
  end

  describe "place item allocation" do
    def place_with(item, quantity)
      Yamshik::Place.new(weight_g: 100, place_items: [Yamshik::PlaceItem.new(item: item, quantity: quantity)])
    end

    it "accepts allocation within the declared quantity" do
      parcel = build_parcel(items: [item], places: [place_with(item, 2), place_with(item, 1)])
      expect(parcel.places.size).to eq(2)
    end

    it "rejects allocation exceeding the declared quantity across places" do
      expect { build_parcel(items: [item], places: [place_with(item, 2), place_with(item, 2)]) }
        .to raise_error(ArgumentError, /exceeds declared quantity/)
    end

    it "rejects place items referencing an unknown item" do
      other = Yamshik::Item.new(name: "Кружка", quantity: 1, price: Yamshik::Money.new(amount: 500))
      expect { build_parcel(items: [item], places: [place_with(other, 1)]) }
        .to raise_error(ArgumentError, /not in the parcel's items/)
    end

    it "skips validation when places carry no place items" do
      expect { build_parcel(places: [Yamshik::Place.new(weight_g: 100)]) }.not_to raise_error
    end
  end
end
