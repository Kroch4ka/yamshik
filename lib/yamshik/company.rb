# frozen_string_literal: true

module Yamshik
  # Legal entity details attached to a {Contact}.
  Company = Data.define(:inn) do
    # @!attribute [r] inn
    #   @return [String] INN (taxpayer identification number)

    # @param inn [String] INN (taxpayer identification number)
    # @raise [ArgumentError] if inn is missing
    def initialize(inn:)
      raise ArgumentError, "inn is required" if inn.nil?

      super
    end
  end
end
