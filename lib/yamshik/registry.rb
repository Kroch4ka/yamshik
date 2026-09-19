# frozen_string_literal: true

module Yamshik
  # Registry of carrier adapters (DESIGN.md §1).
  #
  # Plugin gems register their adapter when required:
  #
  # @example registration inside a plugin (e.g. yamshik-cdek)
  #   Yamshik.register_adapter(:cdek, Yamshik::Cdek::V2::Adapter)
  module Registry
    @adapters = {}

    class << self
      # @param name [Symbol] carrier name
      # @param klass [Class] adapter class implementing the Carrier contract
      # @return [void]
      def register(name, klass)
        @adapters[name.to_sym] = klass
      end

      # @param name [Symbol] carrier name
      # @return [Boolean]
      def registered?(name)
        @adapters.key?(name.to_sym)
      end

      # @param name [Symbol] carrier name
      # @return [Class] the registered adapter class
      # @raise [Yamshik::Error] if no adapter is registered under this name
      def fetch(name)
        @adapters.fetch(name.to_sym) do
          raise Error,
                "no adapter registered for carrier #{name.inspect}; " \
                "did you forget to require the plugin (e.g. require \"yamshik/#{name}\")?"
        end
      end

      # Removes all registered adapters. Intended for tests.
      # @api private
      # @return [void]
      def reset!
        @adapters = {}
      end
    end
  end
end
