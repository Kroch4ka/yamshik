# frozen_string_literal: true

RSpec.describe Yamshik::Status do
  describe ".valid?" do
    it "accepts all canonical statuses" do
      %i[unknown created in_transit ready_for_pickup delivered to_return lost problem].each do |status|
        expect(described_class.valid?(status)).to be(true)
      end
    end

    it "rejects non-canonical statuses" do
      expect(described_class.valid?(:returned)).to be(false)
      expect(described_class.valid?("created")).to be(false)
    end
  end

  describe ".terminal?" do
    it "is true for delivered and lost" do
      expect(described_class.terminal?(:delivered)).to be(true)
      expect(described_class.terminal?(:lost)).to be(true)
    end

    it "is false for non-terminal statuses" do
      %i[unknown created in_transit ready_for_pickup to_return problem].each do |status|
        expect(described_class.terminal?(status)).to be(false)
      end
    end
  end

  describe ".valid_problem_kind?" do
    it "accepts all canonical problem kinds" do
      %i[delay damage customs recipient_unreachable address_issue weight_mismatch payment_issue other].each do |kind|
        expect(described_class.valid_problem_kind?(kind)).to be(true)
      end
    end

    it "rejects non-canonical kinds" do
      expect(described_class.valid_problem_kind?(:aliens)).to be(false)
    end
  end

  describe ".allowed_transition?" do
    it "follows the happy path" do
      expect(described_class.allowed_transition?(:created, :in_transit)).to be(true)
      expect(described_class.allowed_transition?(:in_transit, :ready_for_pickup)).to be(true)
      expect(described_class.allowed_transition?(:ready_for_pickup, :delivered)).to be(true)
    end

    it "allows door delivery skipping ready_for_pickup" do
      expect(described_class.allowed_transition?(:in_transit, :delivered)).to be(true)
    end

    it "allows the return flow" do
      expect(described_class.allowed_transition?(:in_transit, :to_return)).to be(true)
      expect(described_class.allowed_transition?(:ready_for_pickup, :to_return)).to be(true)
      expect(described_class.allowed_transition?(:to_return, :in_transit)).to be(true)
    end

    it "allows loss on any leg" do
      %i[created in_transit ready_for_pickup to_return problem].each do |from|
        expect(described_class.allowed_transition?(from, :lost)).to be(true)
      end
    end

    it "treats problem as a loop from any non-terminal status and back into the flow" do
      %i[created in_transit ready_for_pickup to_return].each do |from|
        expect(described_class.allowed_transition?(from, :problem)).to be(true)
      end
      %i[in_transit ready_for_pickup delivered to_return lost].each do |to|
        expect(described_class.allowed_transition?(:problem, to)).to be(true)
      end
    end

    it "allows nothing from terminal statuses" do
      (described_class::ALL - [:unknown]).each do |to|
        expect(described_class.allowed_transition?(:delivered, to)).to be(false)
        expect(described_class.allowed_transition?(:lost, to)).to be(false)
      end
    end

    it "rejects backwards transitions" do
      expect(described_class.allowed_transition?(:in_transit, :created)).to be(false)
      expect(described_class.allowed_transition?(:ready_for_pickup, :in_transit)).to be(false)
      expect(described_class.allowed_transition?(:created, :delivered)).to be(false)
    end

    it "treats unknown as outside the machine" do
      described_class::ALL.each do |status|
        expect(described_class.allowed_transition?(:unknown, status)).to be(true)
        expect(described_class.allowed_transition?(status, :unknown)).to be(true)
      end
    end
  end
end
