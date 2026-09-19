# frozen_string_literal: true

module Yamshik
  # Value object representing an amount of money.
  #
  # Amounts are always Integer minor units (kopecks for RUB).
  # Conversion from carrier-specific units is the adapter's concern.
  Money = Data.define(:amount, :currency) do
    # @!attribute [r] amount
    #   @return [Integer] amount in minor units (kopecks)
    # @!attribute [r] currency
    #   @return [String] ISO 4217 currency code (e.g. "RUB")

    # @param amount [Integer] amount in minor units (kopecks)
    # @param currency [String] ISO 4217 currency code
    # @raise [ArgumentError] if amount is not an Integer
    def initialize(amount:, currency: "RUB")
      raise ArgumentError, "amount must be an Integer (minor units), got #{amount.inspect}" unless amount.is_a?(Integer)

      super
    end

    # Adds two amounts of the same currency.
    #
    # @param other [Money]
    # @return [Money]
    # @raise [ArgumentError] if currencies differ or other is not Money
    def +(other)
      unless other.is_a?(Money) && other.currency == currency
        raise ArgumentError, "cannot add #{other.inspect} to Money(#{amount}, #{currency})"
      end

      self.class.new(amount: amount + other.amount, currency:)
    end
  end
end
