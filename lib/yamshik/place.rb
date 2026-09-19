# frozen_string_literal: true

module Yamshik
  # A cargo place (package) of a {Parcel}.
  Place = Data.define(:weight_g, :length_cm, :width_cm, :height_cm, :place_items, :labels) do
    # @!attribute [r] weight_g
    #   @return [Integer] gross weight in grams
    # @!attribute [r] length_cm
    #   @return [Integer, nil] length in centimeters
    # @!attribute [r] width_cm
    #   @return [Integer, nil] width in centimeters
    # @!attribute [r] height_cm
    #   @return [Integer, nil] height in centimeters
    # @!attribute [r] place_items
    #   @return [Array<PlaceItem>] item allocation across this place
    # @!attribute [r] labels
    #   @return [Array<PlaceLabel>] shipping labels for this place

    # @param weight_g [Integer] gross weight in grams, must be positive
    # @param length_cm [Integer, nil] length in centimeters, must be positive if given
    # @param width_cm [Integer, nil] width in centimeters, must be positive if given
    # @param height_cm [Integer, nil] height in centimeters, must be positive if given
    # @param place_items [Array<PlaceItem>] item allocation
    # @param labels [Array<PlaceLabel>] shipping labels
    # @raise [ArgumentError] on non-positive weight or dimensions
    def initialize(weight_g:, length_cm: nil, width_cm: nil, height_cm: nil, place_items: [], labels: [])
      validate_positive_integer!(:weight_g, weight_g)
      { length_cm:, width_cm:, height_cm: }.each do |name, value|
        validate_positive_integer!(name, value) if value
      end

      super(weight_g:, length_cm:, width_cm:, height_cm:, place_items: place_items.freeze, labels: labels.freeze)
    end

    private

    def validate_positive_integer!(name, value)
      return if value.is_a?(Integer) && value.positive?

      raise ArgumentError, "#{name} must be a positive Integer, got #{value.inspect}"
    end
  end
end
