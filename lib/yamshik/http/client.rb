# frozen_string_literal: true

require "faraday"

module Yamshik
  module HTTP
    # Faraday-based HTTP client handed to adapters by the core (DESIGN.md §1).
    #
    # Provides what raw Faraday does not:
    # - retries with exponential backoff, distinguishing "definitely not sent"
    #   (connection errors — always retried) from "unknown" (timeout, 429, 5xx —
    #   retried only for idempotent requests, see DESIGN.md §3);
    # - a circuit breaker ({CircuitBreaker}) around every attempt;
    # - mapping of infrastructural failures to the yamshik exception hierarchy
    #   (DESIGN.md §2).
    #
    # Business-level statuses (4xx other than 401/403/429) are returned as
    # responses — mapping them to {CarrierError} is the adapter's concern.
    class Client
      DEFAULT_MAX_RETRIES = 2
      BASE_BACKOFF = 0.25

      # @param base_url [String]
      # @param timeout [Numeric] request timeout in seconds
      # @param logger [Logger, nil]
      # @param breaker [CircuitBreaker]
      # @param max_retries [Integer] retries after the first attempt
      # @param connection [Faraday::Connection, nil] injected connection (tests)
      # @param sleeper [#call] sleep function, injected for tests
      #   @api private
      def initialize(base_url:, timeout: 10, logger: nil, breaker: CircuitBreaker.new,
                     max_retries: DEFAULT_MAX_RETRIES, connection: nil, sleeper: ->(seconds) { sleep(seconds) })
        @timeout = timeout
        @logger = logger
        @breaker = breaker
        @max_retries = max_retries
        @sleeper = sleeper
        @connection = connection || build_connection(base_url)
      end

      # @param path [String]
      # @param params [Hash]
      # @param headers [Hash]
      # @return [Faraday::Response]
      def get(path, params: {}, headers: {})
        request(:get, path, params:, headers:, idempotent: true)
      end

      # @param path [String]
      # @param body [Hash, nil]
      # @param headers [Hash]
      # @param idempotent [Boolean] whether the carrier safely deduplicates this
      #   call (DESIGN.md §3 creation strategies); non-idempotent requests are
      #   retried only when the request definitely did not reach the server
      # @return [Faraday::Response]
      def post(path, body: nil, headers: {}, idempotent: false)
        request(:post, path, body:, headers:, idempotent:)
      end

      # @param path [String]
      # @param body [Hash, nil]
      # @param headers [Hash]
      # @return [Faraday::Response]
      def put(path, body: nil, headers: {})
        request(:put, path, body:, headers:, idempotent: true)
      end

      # @param path [String]
      # @param headers [Hash]
      # @return [Faraday::Response]
      def delete(path, headers: {})
        request(:delete, path, headers:, idempotent: true)
      end

      private

      attr_reader :connection, :timeout, :logger, :breaker, :max_retries, :sleeper

      def build_connection(base_url)
        Faraday.new(url: base_url) do |faraday|
          faraday.request :json
          faraday.options.timeout = timeout
          faraday.adapter Faraday.default_adapter
        end
      end

      def request(method, path, idempotent:, **)
        attempt = 0

        begin
          attempt += 1
          perform(method, path, **)
        rescue ConnectionError
          # The request definitely did not reach the server — always retriable.
          raise if attempt > max_retries

          sleeper.call(backoff(attempt))
          retry
        rescue TimeoutError, CarrierUnavailableError, RateLimitedError => e
          # Ambiguous failure: maybe processed, maybe not (DESIGN.md §3).
          raise if attempt > max_retries || !idempotent

          sleeper.call(retry_delay(e, attempt))
          retry
        end
      end

      def retry_delay(error, attempt)
        error.is_a?(RateLimitedError) && error.retry_after ? error.retry_after : backoff(attempt)
      end

      # One attempt through the circuit breaker. Maps responses and Faraday
      # failures to the yamshik exception hierarchy.
      def perform(method, path, **kwargs)
        breaker.call do
          response = raw_request(method, path, **kwargs)
          handle_status(response)
        end
      rescue Faraday::ConnectionFailed, Faraday::SSLError => e
        raise ConnectionError, e.message
      rescue Faraday::TimeoutError => e
        raise TimeoutError, e.message
      end

      def raw_request(method, path, **kwargs)
        logger&.debug("yamshik #{method.upcase} #{path}")

        connection.public_send(method, path) do |req|
          req.params.update(kwargs[:params]) if kwargs[:params]
          req.headers.update(kwargs[:headers]) if kwargs[:headers]
          req.body = kwargs[:body] if kwargs.key?(:body)
        end
      end

      # @return [Faraday::Response] 2xx and business-level 4xx
      # @raise [AuthenticationError] 401/403
      # @raise [RateLimitedError] 429, with Retry-After when present
      # @raise [CarrierUnavailableError] 5xx
      def handle_status(response)
        case response.status
        when 401, 403 then raise AuthenticationError, "carrier authentication failed (#{response.status})"
        when 429
          raise RateLimitedError.new("carrier rate limited us", retry_after: response.headers["Retry-After"]&.to_f)
        when 500..599 then raise CarrierUnavailableError, "carrier responded #{response.status}"
        end

        response
      end

      def backoff(attempt)
        (BASE_BACKOFF * (2**(attempt - 1))) + (rand * 0.1)
      end
    end
  end
end
