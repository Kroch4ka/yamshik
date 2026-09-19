# frozen_string_literal: true

module Yamshik
  # An additional service of a {Parcel} (two-layer scheme like statuses):
  # a canonical kind plus the carrier's own service code.
  #
  # Non-monetary service parameters go through carrier_options.
  ParcelService = Data.define(:kind, :carrier_code, :amount) do
    # Canonical service kinds.
    const_set(:KINDS, %i[insurance cod try_on sms_notification carrier_specific].freeze)

    # @!attribute [r] kind
    #   @return [Symbol] one of {KINDS}
    # @!attribute [r] carrier_code
    #   @return [String] the carrier's service code
    # @!attribute [r] amount
    #   @return [Money, nil] service price (absent for :try_on, :sms_notification)

    # @param kind [Symbol] one of {KINDS}
    # @param carrier_code [String] the carrier's service code
    # @param amount [Money, nil] service price
    # @raise [ArgumentError] on unknown kind
    def initialize(kind:, carrier_code:, amount: nil)
      unless self.class::KINDS.include?(kind)
        raise ArgumentError, "kind must be one of #{self.class::KINDS.inspect}, got #{kind.inspect}"
      end

      super
    end
  end
end
