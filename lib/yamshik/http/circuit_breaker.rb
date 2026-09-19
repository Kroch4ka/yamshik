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
    # Thread-safe.
    class CircuitBreaker
      # @return [Symbol] :closed, :open or :half_open
      attr_reader :state

      # @param failure_threshold [Integer] consecutive failures before opening
      # @param reset_timeout [Numeric] seconds to wait before the half-open trial
      def initialize(failure_threshold: 5, reset_timeout: 30)
        @failure_threshold = failure_threshold
        @reset_timeout = reset_timeout
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
        transition = @mutex.synchronize { before_call }

        yield.tap { @mutex.synchronize { record_success } }
      rescue CircuitOpenError
        raise
      rescue StandardError
        @mutex.synchronize { record_failure(trial: transition == :half_open) }
        raise
      end

      private

      # @return [Symbol] :proceed or :half_open (trial call)
      def before_call
        return :proceed unless @state == :open
        return reset_for_trial if cooldown_elapsed?

        raise CircuitOpenError, "circuit is open"
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
