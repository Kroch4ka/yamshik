# frozen_string_literal: true

module Yamshik
  # Result of a carrier operation: either a business value or a business error.
  #
  # Business failures are data, not exceptions (DESIGN.md §2): adapters return
  # `Result.ok(parcel)` on success and `Result.err(carrier_error)` when the
  # carrier refuses the operation. Infrastructural failures are raised as
  # exceptions instead (see errors.rb).
  #
  # @example
  #   result = carrier.create_order(parcel)
  #   if result.success?
  #     result.value # => #<Yamshik::Parcel ...>
  #   else
  #     result.error.code # => :validation_failed
  #   end
  class Result
    private_class_method :new

    # @param value [Object] the business value
    # @return [Result] a successful result
    def self.ok(value)
      new(success: true, value:)
    end

    # @param error [CarrierError] the business failure
    # @return [Result] a failed result
    # @raise [ArgumentError] if error is not a {CarrierError}
    def self.err(error)
      raise ArgumentError, "Result.err expects a CarrierError, got #{error.inspect}" unless error.is_a?(CarrierError)

      new(success: false, error:)
    end

    # @return [Boolean]
    def success?
      @success
    end

    # @return [Boolean]
    def failure?
      !@success
    end

    # @return [Object] the business value
    # @raise [RuntimeError] if called on a failed result — this is a caller bug;
    #   check {#success?} first
    def value
      raise "cannot read #value of a failed Result (error: #{@error.inspect})" if failure?

      @value
    end

    # @return [CarrierError] the business error
    # @raise [RuntimeError] if called on a successful result — this is a caller bug;
    #   check {#failure?} first
    def error
      raise "cannot read #error of a successful Result (value: #{@value.inspect})" if success?

      @error
    end

    private

    def initialize(success:, value: nil, error: nil)
      @success = success
      @value = value
      @error = error
      freeze
    end
  end
end
