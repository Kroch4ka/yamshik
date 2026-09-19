# frozen_string_literal: true

module Yamshik
  # Link between an {Item} and a {Place}: which item and how many units
  # are packed into the place.
  PlaceItem = Data.define(:item, :quantity) do
    # @!attribute [r] item
    #   @return [Item] the packed item
    # @!attribute [r] quantity
    #   @return [Integer] number of units in the place

    # @param item [Item] the packed item
    # @param quantity [Integer] number of units, must be positive
    # @raise [ArgumentError] on missing item or non-positive quantity
    def initialize(item:, quantity:)
      raise ArgumentError, "item is required" if item.nil?

      unless quantity.is_a?(Integer) && quantity.positive?
        raise ArgumentError, "quantity must be a positive Integer, got #{quantity.inspect}"
      end

      super
    end
  end
end
