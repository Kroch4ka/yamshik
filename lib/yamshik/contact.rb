# frozen_string_literal: true

module Yamshik
  # A person or organization taking part in a delivery (sender or recipient).
  Contact = Data.define(:name, :company, :phone, :email) do
    # @!attribute [r] name
    #   @return [String] full name of a person or name of an organization
    # @!attribute [r] company
    #   @return [Company, nil] legal entity details
    # @!attribute [r] phone
    #   @return [String] phone number
    # @!attribute [r] email
    #   @return [String, nil] email address

    # @param name [String] full name of a person or name of an organization
    # @param phone [String] phone number
    # @param company [Company, nil] legal entity details
    # @param email [String, nil] email address
    # @raise [ArgumentError] if name or phone is missing
    def initialize(name:, phone:, company: nil, email: nil)
      raise ArgumentError, "name is required" if name.nil?
      raise ArgumentError, "phone is required" if phone.nil?

      super(name:, company:, phone:, email:)
    end
  end
end
