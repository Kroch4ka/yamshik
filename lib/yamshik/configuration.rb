# frozen_string_literal: true

module Yamshik
  # Global configuration of the gem (DESIGN.md §1).
  #
  # @example
  #   Yamshik.configure do |config|
  #     config.register :cdek, client_id: "...", client_secret: "..."
  #     config.default_timeout = 10
  #     config.logger = Logger.new($stdout)
  #     config.on_unknown_status = ->(carrier:, carrier_code:) { MyAlerts.notify(carrier, carrier_code) }
  #   end
  class Configuration
    # @return [Numeric] default HTTP timeout in seconds for carrier clients
    attr_accessor :default_timeout

    # @return [Logger, nil] logger used by the HTTP layer; nil means silence
    attr_accessor :logger

    # @return [#call, nil] hook called when a carrier reports a status code that
    #   does not map to a canonical one (DESIGN.md §7).
    #   Called with keyword arguments: `carrier:` (Symbol), `carrier_code:` (String).
    attr_accessor :on_unknown_status

    def initialize
      @carrier_configs = {}
      @default_timeout = 10
      @logger = nil
      @on_unknown_status = nil
    end

    # Registers a carrier with its adapter-specific configuration.
    #
    # @param name [Symbol] carrier name, e.g. :cdek
    # @param config [Hash] adapter-specific options (credentials, sandbox flag, ...)
    # @return [void]
    def register(name, **config)
      @carrier_configs[name.to_sym] = config
    end

    # @param name [Symbol] carrier name
    # @return [Hash] the config given to {#register}, or an empty Hash
    def carrier_config(name)
      @carrier_configs.fetch(name.to_sym, {})
    end
  end
end
