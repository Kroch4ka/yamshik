# frozen_string_literal: true

module Yamshik
  # A cargo place (package) of a {Parcel}.
  class Place
    # @return [Integer] gross weight in grams
    attr_reader :weight_g
    # @return [Integer, nil] length in centimeters
    attr_reader :length_cm
    # @return [Integer, nil] width in centimeters
    attr_reader :width_cm
    # @return [Integer, nil] height in centimeters
    attr_reader :height_cm
    # @return [Array<PlaceItem>] item allocation across this place
    attr_reader :place_items
    # @return [Array<PlaceLabel>] shipping labels for this place
    attr_reader :labels

    # @param weight_g [Integer] gross weight in grams, must be positive
    # @param length_cm [Integer, nil] length in centimeters, must be positive if given
    # @param width_cm [Integer, nil] width in centimeters, must be positive if given
    # @param height_cm [Integer, nil] height in centimeters, must be positive if given
    # @param place_items [Array<PlaceItem>] item allocation
    # @param labels [Array<PlaceLabel>] shipping labels
    # @raise [ArgumentError] on non-positive weight or dimensions
    def initialize(weight_g:, length_cm: nil, width_cm: nil, height_cm: nil, place_items: [], labels: [])
      @weight_g = weight_g
      @length_cm = length_cm
      @width_cm = width_cm
      @height_cm = height_cm
      @place_items = place_items.freeze
      @labels = labels.freeze
      validate!
      freeze
    end

    private

    def validate!
      validate_positive_integer!(:weight_g, weight_g)
      { length_cm: length_cm, width_cm: width_cm, height_cm: height_cm }.each do |name, value|
        validate_positive_integer!(name, value) if value
      end
    end

    def validate_positive_integer!(name, value)
      return if value.is_a?(Integer) && value.positive?

      raise ArgumentError, "#{name} must be a positive Integer, got #{value.inspect}"
    end
  end
end
