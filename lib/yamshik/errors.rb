# frozen_string_literal: true

module Yamshik
  # Base class for all errors raised by yamshik.
  #
  # Exceptions are raised ONLY for infrastructural failures (network,
  # timeouts, auth, unparseable responses). Business failures are never
  # raised — they are returned as {Result} error values, see {CarrierError}.
  class Error < StandardError; end

  # The carrier API did not respond in time. Transient: retrying is safe
  # according to the adapter's declared creation strategy.
  class TimeoutError < Error; end

  # The request could not be sent at all (DNS, refused connection, ...).
  # The server definitely did not process it — always safe to retry.
  class ConnectionError < Error; end

  # The carrier rejected our credentials. Check the adapter configuration.
  class AuthenticationError < Error; end

  # The carrier returned a response that does not match its documented
  # format (unparseable payload, unexpected schema). This means a broken
  # contract, not a business refusal — please report it to the adapter.
  class InvalidResponseError < Error; end

  # The carrier API answered with 5xx and retries are exhausted.
  # The service is down or misbehaving.
  class CarrierUnavailableError < Error; end

  # The circuit breaker is open: the carrier is failing systematically,
  # calls fail fast without hitting the network (DESIGN.md §1).
  class CircuitOpenError < Error; end

  # The carrier asked us to slow down (HTTP 429), and retries are exhausted.
  class RateLimitedError < Error
    # @return [Numeric, nil] seconds the carrier asked us to wait, if known
    attr_reader :retry_after

    # @param message [String, nil]
    # @param retry_after [Numeric, nil] seconds to wait before the next attempt
    def initialize(message = nil, retry_after: nil)
      @retry_after = retry_after
      super(message)
    end
  end
end
