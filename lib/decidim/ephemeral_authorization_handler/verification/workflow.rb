# frozen_string_literal: true

Decidim::Verifications.register_workflow(:ephemeral_authorization_handler) do |workflow|
  workflow.ephemeral = true
  workflow.engine = Decidim::EphemeralAuthorizationHandler::Verification::Engine
  workflow.admin_engine = Decidim::EphemeralAuthorizationHandler::Verification::AdminEngine
  workflow.expires_in = 1.month
  workflow.renewable = true
  workflow.time_between_renewals = 1.day
end
