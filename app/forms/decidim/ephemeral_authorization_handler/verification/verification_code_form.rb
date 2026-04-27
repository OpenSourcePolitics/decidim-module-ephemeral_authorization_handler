# frozen_string_literal: true

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      class VerificationCodeForm < Form
        attribute :verification, String
        attribute :current_locale, String
        attribute :organization, Decidim::Organization

        validates :verification, presence: true
      end
    end
  end
end
