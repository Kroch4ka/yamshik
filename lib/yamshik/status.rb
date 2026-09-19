# frozen_string_literal: true

module Yamshik
  # Canonical tracking statuses and the reference state machine
  # (DESIGN.md §7).
  #
  # The machine is advisory, not enforced: carriers send events out of
  # order, so the core never rejects "invalid" transitions. Helpers are
  # provided for clients willing to flag anomalies.
  module Status
    UNKNOWN = :unknown
    CREATED = :created
    IN_TRANSIT = :in_transit
    READY_FOR_PICKUP = :ready_for_pickup
    DELIVERED = :delivered
    TO_RETURN = :to_return
    LOST = :lost
    PROBLEM = :problem

    # All canonical statuses.
    ALL = [UNKNOWN, CREATED, IN_TRANSIT, READY_FOR_PICKUP, DELIVERED, TO_RETURN, LOST, PROBLEM].freeze

    # Terminal statuses: no further transitions.
    TERMINAL = [DELIVERED, LOST].freeze

    # Kinds of problems, meaningful only when status is :problem.
    PROBLEM_KINDS = %i[
      delay damage customs recipient_unreachable address_issue weight_mismatch payment_issue other
    ].freeze

    # Allowed transitions of the reference state machine.
    # +unknown+ is intentionally outside the machine.
    TRANSITIONS = {
      CREATED => [IN_TRANSIT, PROBLEM, LOST].freeze,
      IN_TRANSIT => [READY_FOR_PICKUP, DELIVERED, PROBLEM, TO_RETURN, LOST].freeze,
      READY_FOR_PICKUP => [DELIVERED, PROBLEM, TO_RETURN, LOST].freeze,
      TO_RETURN => [IN_TRANSIT, PROBLEM, LOST].freeze,
      PROBLEM => [IN_TRANSIT, READY_FOR_PICKUP, DELIVERED, TO_RETURN, LOST].freeze,
      DELIVERED => [].freeze,
      LOST => [].freeze
    }.freeze

    # @param status [Symbol]
    # @return [Boolean] whether status is a canonical status
    def self.valid?(status)
      ALL.include?(status)
    end

    # @param status [Symbol]
    # @return [Boolean] whether status is terminal (:delivered, :lost)
    def self.terminal?(status)
      TERMINAL.include?(status)
    end

    # @param kind [Symbol]
    # @return [Boolean] whether kind is a canonical problem kind
    def self.valid_problem_kind?(kind)
      PROBLEM_KINDS.include?(kind)
    end

    # Whether a transition is allowed by the reference state machine.
    # +unknown+ is outside the machine: any transition to or from it
    # is considered allowed.
    #
    # @param from [Symbol] current status
    # @param to [Symbol] next status
    # @return [Boolean]
    def self.allowed_transition?(from, to)
      return true if from == UNKNOWN || to == UNKNOWN

      TRANSITIONS.fetch(from, []).include?(to)
    end
  end
end
