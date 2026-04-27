# frozen_string_literal: true

class EphemeralAuthorizationHandler < Decidim::AuthorizationHandler
  # Define the attributes you need for this authorization handler. Attributes
  # are defined using Decidim::AttributeObject
  attribute :phone_number, Integer
  attribute :phone_country, String

  validates :phone_country, presence: true
  validates :phone_number, numericality: { greater_than: 0 }, presence: true

  # If you need to store any of the defined attributes in the authorization you
  # can do it here.
  #
  # You must return a Hash that will be serialized to the authorization when
  # it is created, and available though authorization.metadata
  def metadata
    super.merge(phone_number:, phone_country:)
  end

  # If set, enforces the handler to validate the uniqueness of the field
  def unique_id
    return nil if phone_number.blank?

    Decidim::EphemeralAuthorizationHandler::PhoneNumberFormatter.new(phone_number:, iso_country_code: phone_country).format
  end

  def self.ephemeral?
    true
  end
end
