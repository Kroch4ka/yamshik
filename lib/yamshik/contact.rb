# frozen_string_literal: true

module Yamshik
  # A person or organization taking part in a delivery (sender or recipient).
  class Contact
    # @return [String] full name of a person or name of an organization
    attr_reader :name
    # @return [Company, nil] legal entity details
    attr_reader :company
    # @return [String] phone number
    attr_reader :phone
    # @return [String, nil] email address
    attr_reader :email

    # @param name [String] full name of a person or name of an organization
    # @param phone [String] phone number
    # @param company [Company, nil] legal entity details
    # @param email [String, nil] email address
    def initialize(name:, phone:, company: nil, email: nil)
      raise ArgumentError, "name is required" if name.nil?
      raise ArgumentError, "phone is required" if phone.nil?

      @name = name
      @phone = phone
      @company = company
      @email = email
      freeze
    end
  end
end
