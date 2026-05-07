# frozen_string_literal: true

Decidim::Verifications.register_workflow(:ephemeral_authorization_handler) do |workflow|
  workflow.ephemeral = true
  workflow.engine = Decidim::EphemeralAuthorizationHandler::Verification::Engine
  
  module_configuration = Decidim::EphemeralAuthorizationHandler.config
  workflow.expires_in = module_configuration.expires_in
  workflow.renewable = module_configuration.renewable
  workflow.time_between_renewals = module_configuration.time_between_renewals
end
