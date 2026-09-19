# frozen_string_literal: true

module Yamshik
  module HTTP
    # Default response classifier: decides whether a response is a success,
    # a business-level answer (returned to the adapter) or an infrastructural
    # failure (raised, counted by the circuit breaker).
    #
    # Plugins with quirky carriers replace or wrap it via `Client.new(classifier:)`:
    # a carrier reporting unavailability in a 200 body should raise
    # {CarrierUnavailableError} from a custom classifier; a carrier reporting
    # validation errors as 500 should return such responses untouched, so the
    # adapter can map them to {CarrierError} (DESIGN.md §1).
    module StatusClassifier
      module_function

      # @param response [Faraday::Response]
      # @return [Faraday::Response] 2xx and business-level 4xx
      # @raise [AuthenticationError] 401/403
      # @raise [RateLimitedError] 429, with Retry-After when present
      # @raise [CarrierUnavailableError] 5xx
      def call(response)
        case response.status
        when 401, 403 then raise AuthenticationError, "carrier authentication failed (#{response.status})"
        when 429
          raise RateLimitedError.new("carrier rate limited us", retry_after: response.headers["Retry-After"]&.to_f)
        when 500..599 then raise CarrierUnavailableError, "carrier responded #{response.status}"
        end

        response
      end
    end
  end
end
