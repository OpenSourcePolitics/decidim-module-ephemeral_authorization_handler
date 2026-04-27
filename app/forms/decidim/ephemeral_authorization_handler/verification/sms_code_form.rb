# frozen_string_literal: true

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      class SmsCodeForm < Form
        attribute :phone_number, Integer
        attribute :phone_country, String

        validates :phone_country, presence: true
        validates :phone_number, numericality: { greater_than: 0 }, presence: true
      end
    end
  end
end
