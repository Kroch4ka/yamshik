# frozen_string_literal: true

module Yamshik
  # Legal entity details attached to a {Contact}.
  class Company
    # @return [String] INN (taxpayer identification number)
    attr_reader :inn

    # @param inn [String] INN (taxpayer identification number)
    def initialize(inn:)
      raise ArgumentError, "inn is required" if inn.nil?

      @inn = inn
      freeze
    end
  end
end
