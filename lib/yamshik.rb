# frozen_string_literal: true

require_relative "yamshik/version"
require_relative "yamshik/errors"
require_relative "yamshik/carrier_error"
require_relative "yamshik/result"
require_relative "yamshik/configuration"
require_relative "yamshik/registry"
require_relative "yamshik/money"
require_relative "yamshik/company"
require_relative "yamshik/contact"
require_relative "yamshik/point"
require_relative "yamshik/item"
require_relative "yamshik/place_item"
require_relative "yamshik/place_label"
require_relative "yamshik/place"
require_relative "yamshik/parcel_service"
require_relative "yamshik/status"
require_relative "yamshik/parcel"
require_relative "yamshik/tracking_event"

# Yamshik is a core gem that defines a unified domain model and carrier
# contract for Russian delivery services. Carrier integrations live in
# separate plugin gems (e.g. yamshik-cdek).
#
# @example
#   Yamshik.configure do |config|
#     config.register :cdek, client_id: "...", client_secret: "..."
#   end
#
#   cdek = Yamshik.carrier(:cdek)
module Yamshik
  class << self
    # @return [Configuration] the global configuration (memoized)
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the global configuration.
    #
    # @yieldparam config [Configuration]
    # @return [void]
    def configure
      yield configuration
    end

    # Registers a carrier adapter. Called by plugin gems when required.
    #
    # @param name [Symbol] carrier name, e.g. :cdek
    # @param klass [Class] adapter class implementing the Carrier contract
    # @return [void]
    def register_adapter(name, klass)
      Registry.register(name, klass)
    end

    # Builds an adapter instance for a registered carrier, configured with
    # the options given to {Configuration#register}.
    #
    # @param name [Symbol] carrier name, e.g. :cdek
    # @return [Carrier] the configured adapter instance
    # @raise [Yamshik::Error] if no adapter is registered under this name
    def carrier(name)
      Registry.fetch(name).new(**configuration.carrier_config(name))
    end

    # Resets configuration and adapter registry. Intended for tests.
    # @api private
    # @return [void]
    def reset!
      @configuration = nil
      Registry.reset!
    end
  end
end
