# frozen_string_literal: true

module Yamshik
  # Business-level failure returned by a carrier, as data (not an exception).
  #
  # Carriers refuse operations for business reasons: invalid params, unknown
  # orders, unsupported routes. These are expected outcomes, so they are
  # returned inside {Result} instead of being raised. See DESIGN.md §2.
  #
  # @example
  #   error = Yamshik::CarrierError.new(
  #     code: :validation_failed,
  #     carrier: :cdek,
  #     message: "weight is required",
  #     details: { path: "places[0].weight_g" }
  #   )
  CarrierError = Data.define(:code, :carrier, :message, :details, :raw, :carrier_code) do
    # @!attribute [r] code
    #   @return [Symbol] canonical code from {CarrierError::CODES}
    # @!attribute [r] carrier
    #   @return [Symbol] carrier that produced the error (e.g. :cdek)
    # @!attribute [r] message
    #   @return [String] human-readable description from the carrier
    # @!attribute [r] details
    #   @return [Hash, nil] structured details (e.g. failing attribute path)
    # @!attribute [r] raw
    #   @return [Hash, nil] raw carrier payload, when available
    # @!attribute [r] carrier_code
    #   @return [String, nil] the carrier's own error code, when available

    # @param code [Symbol] one of {CarrierError::CODES}
    # @param carrier [Symbol]
    # @param message [String]
    # @param details [Hash, nil]
    # @param raw [Hash, nil]
    # @param carrier_code [String, nil]
    # @raise [ArgumentError] if code is unknown or required fields are missing
    def initialize(code:, carrier:, message:, details: nil, raw: nil, carrier_code: nil)
      unless self.class::CODES.include?(code)
        raise ArgumentError, "code must be one of #{self.class::CODES.inspect}, got #{code.inspect}"
      end
      raise ArgumentError, "carrier must be a Symbol, got #{carrier.inspect}" unless carrier.is_a?(Symbol)
      raise ArgumentError, "message must be a String, got #{message.inspect}" unless message.is_a?(String)

      super
    end
  end

  # Canonical business error codes (DESIGN.md §2).
  CarrierError::CODES = %i[
    validation_failed
    duplicate
    not_found
    route_not_supported
    rejected
    other
  ].freeze
end
