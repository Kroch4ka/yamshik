# frozen_string_literal: true

module Yamshik
  # An additional service of a {Parcel} (two-layer scheme like statuses):
  # a canonical kind plus the carrier's own service code.
  #
  # Non-monetary service parameters go through carrier_options.
  class ParcelService
    # Canonical service kinds.
    KINDS = %i[insurance cod try_on sms_notification carrier_specific].freeze

    # @return [Symbol] one of {KINDS}
    attr_reader :kind
    # @return [String] the carrier's service code
    attr_reader :carrier_code
    # @return [Money, nil] service price (absent for :try_on, :sms_notification)
    attr_reader :amount

    # @param kind [Symbol] one of {KINDS}
    # @param carrier_code [String] the carrier's service code
    # @param amount [Money, nil] service price
    # @raise [ArgumentError] on unknown kind
    def initialize(kind:, carrier_code:, amount: nil)
      raise ArgumentError, "kind must be one of #{KINDS.inspect}, got #{kind.inspect}" unless KINDS.include?(kind)

      @kind = kind
      @carrier_code = carrier_code
      @amount = amount
      freeze
    end
  end
end
