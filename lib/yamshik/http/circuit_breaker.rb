# frozen_string_literal: true

module Yamshik
  module HTTP
    # Minimal circuit breaker: closed → open → half-open (DESIGN.md §1).
    #
    # Counts consecutive infrastructural failures; after +failure_threshold+
    # the circuit opens and calls fail fast with {CircuitOpenError} without
    # hitting the network. After +reset_timeout+ seconds a single trial call
    # is let through (half-open): success closes the circuit, failure re-opens it.
    #
    # By default only yamshik infrastructural errors are counted
    # ({INFRA_ERRORS}); programmer errors propagate without feeding the
    # breaker. Plugins may override what counts via +count_failure:+
    # (e.g. a carrier whose 429 is a soft limit should not open the circuit).
    #
    # Thread-safe.
    class CircuitBreaker
      # Errors counted as carrier-unavailability symptoms by default.
      INFRA_ERRORS = [TimeoutError, ConnectionError, CarrierUnavailableError, RateLimitedError].freeze

      # @return [Symbol] :closed, :open or :half_open
      attr_reader :state

      # @param failure_threshold [Integer] consecutive failures before opening
      # @param reset_timeout [Numeric] seconds to wait before the half-open trial
      # @param count_failure [#call, nil] predicate receiving the raised error,
      #   returning whether it counts toward opening the circuit;
      #   defaults to {INFRA_ERRORS} only
      def initialize(failure_threshold: 5, reset_timeout: 30, count_failure: nil)
        @failure_threshold = failure_threshold
        @reset_timeout = reset_timeout
        @count_failure = count_failure || ->(error) { INFRA_ERRORS.any? { |klass| error.is_a?(klass) } }
        @state = :closed
        @consecutive_failures = 0
        @opened_at = nil
        @mutex = Mutex.new
      end

      # Runs the block through the breaker.
      #
      # @yield the network call
      # @return [Object] the block's result
      # @raise [CircuitOpenError] if the circuit is open
      def call(&)
        trial = @mutex.synchronize { before_call } == :half_open

        yield.tap { @mutex.synchronize { record_success } }
      rescue StandardError => e
        @mutex.synchronize { record_failure(trial:) } if counts?(e)

        raise
      end

      private

      # @return [Symbol] :proceed or :half_open (trial call)
      def before_call
        return :proceed unless @state == :open
        return reset_for_trial if cooldown_elapsed?

        raise CircuitOpenError, "circuit is open"
      end

      def counts?(error)
        @count_failure.call(error)
      end

      def cooldown_elapsed?
        monotonic_now - @opened_at >= @reset_timeout
      end

      def reset_for_trial
        @state = :half_open
        :half_open
      end

      def record_success
        @state = :closed
        @consecutive_failures = 0
        @opened_at = nil
      end

      def record_failure(trial:)
        @consecutive_failures += 1
        open! if trial || @consecutive_failures >= @failure_threshold
      end

      def open!
        @state = :open
        @opened_at = monotonic_now
      end

      def monotonic_now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
    end
  end
end
