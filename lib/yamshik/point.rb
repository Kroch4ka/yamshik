# frozen_string_literal: true

module Yamshik
  # An origin or destination of a delivery.
  #
  # Validity of the address / pickup point code combination is checked
  # by the adapter, not by the core.
  class Point
    # @return [String] ISO 3166-1 alpha-2 country code
    attr_reader :country_code
    # @return [String, nil] region name
    attr_reader :region
    # @return [String] city name
    attr_reader :city
    # @return [String, nil] street, building, apartment as a single line
    attr_reader :address
    # @return [String, nil] postal code
    attr_reader :index
    # @return [String, nil] carrier's pickup point code
    attr_reader :pickup_point_code

    # @param city [String] city name
    # @param country_code [String] ISO 3166-1 alpha-2 country code
    # @param region [String, nil] region name
    # @param address [String, nil] street, building, apartment as a single line
    # @param index [String, nil] postal code
    # @param pickup_point_code [String, nil] carrier's pickup point code
    def initialize(city:, country_code: "RU", region: nil, address: nil, index: nil, pickup_point_code: nil)
      raise ArgumentError, "city is required" if city.nil?

      @country_code = country_code
      @region = region
      @city = city
      @address = address
      @index = index
      @pickup_point_code = pickup_point_code
      freeze
    end

    # Point kind, derived from the presence of a pickup point code.
    #
    # @return [Symbol] :pickup_point if pickup_point_code is set, :door otherwise
    def type
      pickup_point_code ? :pickup_point : :door
    end
  end
end
