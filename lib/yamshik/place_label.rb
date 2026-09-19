# frozen_string_literal: true

module Yamshik
  # A shipping label for a {Place}: either binary content or a URL
  # (some carriers return a link instead of the label itself).
  PlaceLabel = Data.define(:format, :content, :url) do
    # Supported label formats.
    const_set(:FORMATS, %i[pdf png zpl].freeze)

    # @!attribute [r] format
    #   @return [Symbol] one of {FORMATS}
    # @!attribute [r] content
    #   @return [String, nil] binary label content
    # @!attribute [r] url
    #   @return [String, nil] URL to download the label

    # @param format [Symbol] one of {FORMATS}
    # @param content [String, nil] binary label content
    # @param url [String, nil] URL to download the label
    # @raise [ArgumentError] on unknown format or when neither content nor url is given
    def initialize(format:, content: nil, url: nil)
      unless self.class::FORMATS.include?(format)
        raise ArgumentError, "format must be one of #{self.class::FORMATS.inspect}, got #{format.inspect}"
      end
      raise ArgumentError, "either content or url must be given" if content.nil? && url.nil?

      super
    end
  end
end
