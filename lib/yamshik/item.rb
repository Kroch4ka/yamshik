# frozen_string_literal: true

module Yamshik
  # A declared content line of a {Parcel}.
  class Item
    # @return [String] product name
    attr_reader :name
    # @return [String, nil] SKU / article number
    attr_reader :sku
    # @return [Integer] number of units
    attr_reader :quantity
    # @return [Money] price per unit
    attr_reader :price
    # @return [Integer, nil] weight of one unit in grams
    attr_reader :weight_g
    # @return [Integer, nil] VAT rate
    attr_reader :vat_rate

    # @param name [String] product name
    # @param quantity [Integer] number of units, must be positive
    # @param price [Money] price per unit
    # @param sku [String, nil] SKU / article number
    # @param weight_g [Integer, nil] weight of one unit in grams, must be positive if given
    # @param vat_rate [Integer, nil] VAT rate
    # @raise [ArgumentError] on missing name/price or non-positive quantity/weight
    def initialize(name:, quantity:, price:, sku: nil, weight_g: nil, vat_rate: nil)
      @name = name
      @sku = sku
      @quantity = quantity
      @price = price
      @weight_g = weight_g
      @vat_rate = vat_rate
      validate!
      freeze
    end

    private

    def validate!
      raise ArgumentError, "name is required" if name.nil?
      raise ArgumentError, "price is required" if price.nil?

      validate_positive_integer!(:quantity, quantity)
      validate_positive_integer!(:weight_g, weight_g) if weight_g
    end

    def validate_positive_integer!(name, value)
      return if value.is_a?(Integer) && value.positive?

      raise ArgumentError, "#{name} must be a positive Integer, got #{value.inspect}"
    end
  end
end
