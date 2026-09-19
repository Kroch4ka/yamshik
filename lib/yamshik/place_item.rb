# frozen_string_literal: true

module Yamshik
  # Link between an {Item} and a {Place}: which item and how many units
  # are packed into the place.
  class PlaceItem
    # @return [Item] the packed item
    attr_reader :item
    # @return [Integer] number of units in the place
    attr_reader :quantity

    # @param item [Item] the packed item
    # @param quantity [Integer] number of units, must be positive
    # @raise [ArgumentError] on missing item or non-positive quantity
    def initialize(item:, quantity:)
      @item = item
      @quantity = quantity
      validate!
      freeze
    end

    private

    def validate!
      raise ArgumentError, "item is required" if item.nil?

      return if quantity.is_a?(Integer) && quantity.positive?

      raise ArgumentError, "quantity must be a positive Integer, got #{quantity.inspect}"
    end
  end
end
