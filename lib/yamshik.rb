# frozen_string_literal: true

require_relative "yamshik/version"
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

module Yamshik
  class Error < StandardError; end
end
