# frozen_string_literal: true

module Yamshik
  # A single tracking event of a shipment.
  TrackingEvent = Data.define(:status, :problem_kind, :carrier_code, :occurred_at, :raw) do
    # @!attribute [r] status
    #   @return [Symbol] canonical status (see {Status})
    # @!attribute [r] problem_kind
    #   @return [Symbol, nil] problem kind, only when status is :problem
    # @!attribute [r] carrier_code
    #   @return [String] the carrier's raw event code
    # @!attribute [r] occurred_at
    #   @return [Time] when the event happened
    # @!attribute [r] raw
    #   @return [Hash, nil] raw carrier payload

    # @param status [Symbol] canonical status (see {Status})
    # @param carrier_code [String] the carrier's raw event code
    # @param occurred_at [Time] when the event happened
    # @param problem_kind [Symbol, nil] problem kind, only allowed when status is :problem
    # @param raw [Hash, nil] raw carrier payload
    # @raise [ArgumentError] on unknown status/problem_kind, or problem_kind
    #   given for a non-problem status
    def initialize(status:, carrier_code:, occurred_at:, problem_kind: nil, raw: nil)
      raise ArgumentError, "carrier_code is required" if carrier_code.nil?
      raise ArgumentError, "occurred_at is required" if occurred_at.nil?

      validate_status!(status)
      validate_problem_kind!(status, problem_kind) if problem_kind

      super
    end

    private

    def validate_status!(status)
      return if Status.valid?(status)

      raise ArgumentError, "status must be one of #{Status::ALL.inspect}, got #{status.inspect}"
    end

    def validate_problem_kind!(status, problem_kind)
      raise ArgumentError, "problem_kind is only allowed when status is :problem" unless status == Status::PROBLEM
      return if Status.valid_problem_kind?(problem_kind)

      raise ArgumentError, "problem_kind must be one of #{Status::PROBLEM_KINDS.inspect}, got #{problem_kind.inspect}"
    end
  end
end
