# frozen_string_literal: true

module Yamshik
  # Maps carrier-specific status codes to canonical statuses (DESIGN.md §7).
  #
  # Adapters declare the mapping as data; the core validates that targets are
  # canonical. Unknown carrier codes map to :unknown and trigger the
  # +on_unknown_status+ hook (Configuration).
  #
  # @example
  #   mapper = Yamshik::StatusMapper.new(carrier: :cdek, mapping: { "ACCEPTED" => :created, ... })
  #   mapper.map("ACCEPTED") # => :created
  class StatusMapper
    # @param carrier [Symbol] carrier key (for the hook payload)
    # @param mapping [Hash{String => Symbol}] carrier code => canonical status
    # @raise [ArgumentError] if a mapping target is not a canonical status
    def initialize(carrier:, mapping:)
      @carrier = carrier
      validate_targets!(mapping)
      @mapping = mapping.transform_keys(&:to_s).freeze
    end

    # @param carrier_code [String, Object] the carrier's own status code
    # @return [Symbol] canonical status; :unknown for unmapped codes
    def map(carrier_code)
      @mapping.fetch(carrier_code.to_s) { unknown(carrier_code) }
    end

    private

    def validate_targets!(mapping)
      mapping.each_value do |status|
        next if Status.valid?(status)

        raise ArgumentError, "status mapping targets must be canonical (#{Status::ALL.inspect}), got #{status.inspect}"
      end
    end

    def unknown(carrier_code)
      Yamshik.configuration.on_unknown_status&.call(carrier: @carrier, carrier_code: carrier_code.to_s)
      :unknown
    end
  end
end
