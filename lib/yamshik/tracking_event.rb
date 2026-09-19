# frozen_string_literal: true

module Yamshik
  # A single tracking event of a shipment.
  class TrackingEvent
    # @return [Symbol] canonical status (see {Status})
    attr_reader :status
    # @return [Symbol, nil] problem kind, only when status is :problem
    attr_reader :problem_kind
    # @return [String] the carrier's raw event code
    attr_reader :carrier_code
    # @return [Time] when the event happened
    attr_reader :occurred_at
    # @return [Hash, nil] raw carrier payload
    attr_reader :raw

    # @param status [Symbol] canonical status (see {Status})
    # @param carrier_code [String] the carrier's raw event code
    # @param occurred_at [Time] when the event happened
    # @param problem_kind [Symbol, nil] problem kind, only allowed when status is :problem
    # @param raw [Hash, nil] raw carrier payload
    # @raise [ArgumentError] on unknown status/problem_kind, or problem_kind
    #   given for a non-problem status
    def initialize(status:, carrier_code:, occurred_at:, problem_kind: nil, raw: nil)
      @status = status
      @problem_kind = problem_kind
      @carrier_code = carrier_code
      @occurred_at = occurred_at
      @raw = raw
      validate!
      freeze
    end

    private

    def validate!
      raise ArgumentError, "carrier_code is required" if carrier_code.nil?
      raise ArgumentError, "occurred_at is required" if occurred_at.nil?

      validate_status!
      validate_problem_kind! if problem_kind
    end

    def validate_status!
      return if Status.valid?(status)

      raise ArgumentError, "status must be one of #{Status::ALL.inspect}, got #{status.inspect}"
    end

    def validate_problem_kind!
      raise ArgumentError, "problem_kind is only allowed when status is :problem" unless status == Status::PROBLEM
      return if Status.valid_problem_kind?(problem_kind)

      raise ArgumentError, "problem_kind must be one of #{Status::PROBLEM_KINDS.inspect}, got #{problem_kind.inspect}"
    end
  end
end
