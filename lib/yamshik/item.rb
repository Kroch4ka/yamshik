# frozen_string_literal: true

module Yamshik
  # A declared content line of a {Parcel}.
  Item = Data.define(:name, :sku, :quantity, :price, :weight_g, :vat_rate) do
    # @!attribute [r] name
    #   @return [String] product name
    # @!attribute [r] sku
    #   @return [String, nil] SKU / article number
    # @!attribute [r] quantity
    #   @return [Integer] number of units
    # @!attribute [r] price
    #   @return [Money] price per unit
    # @!attribute [r] weight_g
    #   @return [Integer, nil] weight of one unit in grams
    # @!attribute [r] vat_rate
    #   @return [Integer, nil] VAT rate

    # @param name [String] product name
    # @param quantity [Integer] number of units, must be positive
    # @param price [Money] price per unit
    # @param sku [String, nil] SKU / article number
    # @param weight_g [Integer, nil] weight of one unit in grams, must be positive if given
    # @param vat_rate [Integer, nil] VAT rate
    # @raise [ArgumentError] on missing name/price or non-positive quantity/weight
    def initialize(name:, quantity:, price:, sku: nil, weight_g: nil, vat_rate: nil)
      raise ArgumentError, "name is required" if name.nil?
      raise ArgumentError, "price is required" if price.nil?

      validate_positive_integer!(:quantity, quantity)
      validate_positive_integer!(:weight_g, weight_g) if weight_g

      super(name:, sku:, quantity:, price:, weight_g:, vat_rate:)
    end

    private

    def validate_positive_integer!(name, value)
      return if value.is_a?(Integer) && value.positive?

      raise ArgumentError, "#{name} must be a positive Integer, got #{value.inspect}"
    end
  end
end
