# frozen_string_literal: true

require "rspec"

module Yamshik
  module Spec
    # Contract test suite for carrier adapters (DESIGN.md §1).
    #
    # Every plugin runs it in its own spec suite — the contract is enforced
    # by tests, not by hope. Requires +carrier+ and +valid_parcel+ lets:
    #
    # @example plugin usage
    #   require "yamshik/spec/contract"
    #
    #   RSpec.describe Yamshik::Cdek::V2::Adapter do
    #     it_behaves_like "a yamshik carrier" do
    #       let(:carrier) { described_class.new(client_id: "...", client_secret: "...") }
    #       let(:valid_parcel) { ... } # a Yamshik::Parcel the carrier accepts
    #       let(:carrier_options) { { tariff_code: "136" } } # when creation requires options
    #     end
    #   end
    module Contract
      RSpec.shared_examples "a yamshik carrier" do
        # Plugins override this when their carrier requires carrier_options
        # for order creation (e.g. CDEK needs a tariff_code).
        let(:carrier_options) { {} }

        it "implements the Carrier contract" do
          expect(carrier).to be_a(Yamshik::Carrier)
        end

        it "declares a known creation strategy" do
          expect(Yamshik::Carrier::CREATION_STRATEGIES).to include(carrier.class.creation_strategy)
        end

        describe "#create_order" do
          subject(:result) { carrier.create_order(valid_parcel, carrier_options:) }

          it "returns a successful Result with a registered Parcel" do
            expect(result).to be_a(Yamshik::Result)
            expect(result).to be_success

            parcel = result.value
            expect(parcel).to be_a(Yamshik::Parcel)
            expect(parcel.external_id).not_to be_nil
            expect(parcel.carrier).to be_a(Symbol)
            expect(Yamshik::Parcel::REGISTRATION_STATES).to include(parcel.registration_state)
          end

          context "with an idempotent creation strategy" do
            it "returns the same parcel for a repeated reference" do
              skip "carrier is not idempotent" unless carrier.class.creation_strategy == :idempotent

              first = carrier.create_order(valid_parcel, carrier_options:)
              second = carrier.create_order(valid_parcel, carrier_options:)

              expect(second.value.external_id).to eq(first.value.external_id)
            end
          end

          context "with a business refusal" do
            it "returns Result.err with a canonical CarrierError code" do
              result = carrier.create_order(valid_parcel, carrier_options: { __contract_invalid__: true })

              skip "adapter accepted the probe" if result.success?

              expect(result.error).to be_a(Yamshik::CarrierError)
              expect(Yamshik::CarrierError::CODES).to include(result.error.code)
            end
          end
        end

        describe "#parcel" do
          it "returns the created parcel by external_id" do
            created = carrier.create_order(valid_parcel, carrier_options:).value
            result = carrier.parcel(created.external_id)

            expect(result).to be_success
            expect(result.value.external_id).to eq(created.external_id)
          end

          it "returns a :not_found CarrierError for unknown ids" do
            result = carrier.parcel("definitely-missing-id")

            expect(result).to be_failure
            expect(result.error).to be_a(Yamshik::CarrierError)
            expect(result.error.code).to eq(:not_found)
          end
        end
      end
    end
  end
end
