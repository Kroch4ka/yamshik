# frozen_string_literal: true

module Yamshik
  module Adapters
    # In-memory reference adapter (DESIGN.md §1).
    #
    # Serves three purposes: a living example for plugin authors, the subject
    # of the contract test suite in the core's CI, and a test double for users
    # of the gem (registered as :fake).
    #
    # Implements idempotent creation: a repeated create_order with the same
    # +reference+ returns the existing parcel.
    class Fake < Carrier
      creation_strategy :idempotent

      def initialize(**)
        super()
        @parcels = {}
        @sequence = 0
        @mutex = Mutex.new
      end

      # @see Carrier#create_order
      #
      # Fake accepts no carrier_options at all: any key is rejected with
      # :validation_failed — the reference behavior every adapter should have
      # for unknown carrier_options (DESIGN.md §5).
      def create_order(parcel, carrier_options: {})
        return reject_unknown_options(carrier_options) unless carrier_options.empty?

        existing = find_by_reference(parcel.reference)
        return Result.ok(existing) if existing

        Result.ok(register(parcel))
      end

      # @see Carrier#parcel
      def parcel(external_id)
        found = @mutex.synchronize { @parcels[external_id] }
        return Result.ok(found) if found

        Result.err(CarrierError.new(code: :not_found, carrier: :fake,
                                    message: "no parcel with external_id #{external_id.inspect}"))
      end

      private

      def reject_unknown_options(carrier_options)
        Result.err(CarrierError.new(code: :validation_failed, carrier: :fake,
                                    message: "unknown carrier_options keys: #{carrier_options.keys.inspect}",
                                    details: { path: "carrier_options" }))
      end

      def find_by_reference(reference)
        @mutex.synchronize { @parcels.values.find { |stored| stored.reference == reference } }
      end

      def register(parcel)
        @mutex.synchronize do
          @sequence += 1
          Parcel.new(**parcel.to_h, external_id: "FAKE-#{@sequence}",
                                    carrier: :fake, registration_state: :registered).tap do |registered|
            @parcels[registered.external_id] = registered
          end
        end
      end
    end

    Yamshik::Registry.register(:fake, Fake)
  end
end
