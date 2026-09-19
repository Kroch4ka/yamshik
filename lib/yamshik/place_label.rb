# frozen_string_literal: true

module Yamshik
  # A shipping label for a {Place}: either binary content or a URL
  # (some carriers return a link instead of the label itself).
  class PlaceLabel
    # Supported label formats.
    FORMATS = %i[pdf png zpl].freeze

    # @return [Symbol] one of {FORMATS}
    attr_reader :format
    # @return [String, nil] binary label content
    attr_reader :content
    # @return [String, nil] URL to download the label
    attr_reader :url

    # @param format [Symbol] one of {FORMATS}
    # @param content [String, nil] binary label content
    # @param url [String, nil] URL to download the label
    # @raise [ArgumentError] on unknown format or when neither content nor url is given
    def initialize(format:, content: nil, url: nil)
      unless FORMATS.include?(format)
        raise ArgumentError, "format must be one of #{FORMATS.inspect}, got #{format.inspect}"
      end
      raise ArgumentError, "either content or url must be given" if content.nil? && url.nil?

      @format = format
      @content = content
      @url = url
      freeze
    end
  end
end
