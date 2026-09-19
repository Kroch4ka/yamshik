# frozen_string_literal: true

module Yamshik
  # An origin or destination of a delivery.
  #
  # Validity of the address / pickup point code combination is checked
  # by the adapter, not by the core.
  Point = Data.define(:country_code, :region, :city, :address, :index, :pickup_point_code) do
    # @!attribute [r] country_code
    #   @return [String] ISO 3166-1 alpha-2 country code
    # @!attribute [r] region
    #   @return [String, nil] region name
    # @!attribute [r] city
    #   @return [String] city name
    # @!attribute [r] address
    #   @return [String, nil] street, building, apartment as a single line
    # @!attribute [r] index
    #   @return [String, nil] postal code
    # @!attribute [r] pickup_point_code
    #   @return [String, nil] carrier's pickup point code

    # @param city [String] city name
    # @param country_code [String] ISO 3166-1 alpha-2 country code
    # @param region [String, nil] region name
    # @param address [String, nil] street, building, apartment as a single line
    # @param index [String, nil] postal code
    # @param pickup_point_code [String, nil] carrier's pickup point code
    # @raise [ArgumentError] if city is missing
    def initialize(city:, country_code: "RU", region: nil, address: nil, index: nil, pickup_point_code: nil)
      raise ArgumentError, "city is required" if city.nil?

      super(country_code:, region:, city:, address:, index:, pickup_point_code:)
    end

    # Point kind, derived from the presence of a pickup point code.
    #
    # @return [Symbol] :pickup_point if pickup_point_code is set, :door otherwise
    def type
      pickup_point_code ? :pickup_point : :door
    end
  end
end
