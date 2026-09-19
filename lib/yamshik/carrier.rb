# frozen_string_literal: true

module Yamshik
  # Abstract carrier contract — the public API that plugin gems implement
  # (DESIGN.md §1). Part of the gem's semver surface: breaking changes here
  # require a major version.
  #
  # Plugins subclass it and register themselves:
  #
  # @example
  #   class Yamshik::Cdek::V2::Adapter < Yamshik::Carrier
  #     creation_strategy :idempotent
  #
  #     def create_order(parcel, carrier_options: {}) = ...
  #     def parcel(external_id) = ...
  #   end
  class Carrier
    # How the carrier handles duplicate creation requests (DESIGN.md §3).
    CREATION_STRATEGIES = %i[idempotent check_on_ambiguous unsafe].freeze

    class << self
      # Declares (or reads) the creation strategy of the carrier.
      #
      # @param strategy [Symbol, nil] one of {CREATION_STRATEGIES}
      # @return [Symbol] the declared strategy, :unsafe when undeclared
      # @raise [ArgumentError] on an unknown strategy
      def creation_strategy(strategy = nil)
        return @creation_strategy || :unsafe unless strategy

        unless CREATION_STRATEGIES.include?(strategy)
          raise ArgumentError,
                "creation_strategy must be one of #{CREATION_STRATEGIES.inspect}, got #{strategy.inspect}"
        end

        @creation_strategy = strategy
      end
    end

    # Creates a shipment at the carrier.
    #
    # @param parcel [Parcel] must carry +reference+ (idempotency anchor)
    # @param carrier_options [Hash] carrier-specific extras, validated by the
    #   adapter (DESIGN.md §5); errors carry the failing path in details
    # @return [Result] ok(Parcel) — possibly with registration_state :pending
    #   (async registration, DESIGN.md §4) — or err(CarrierError)
    def create_order(parcel, carrier_options: {})
      raise NotImplementedError, "#{self.class} must implement #create_order"
    end

    # Refreshes a shipment state by its carrier-side id.
    #
    # @param external_id [String]
    # @return [Result] ok(Parcel) or err(CarrierError) with code :not_found
    def parcel(external_id)
      raise NotImplementedError, "#{self.class} must implement #parcel"
    end
  end
end
