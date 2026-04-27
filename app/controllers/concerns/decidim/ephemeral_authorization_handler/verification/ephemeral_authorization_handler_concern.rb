# frozen_string_literal: true

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      module EphemeralAuthorizationHandlerConcern
        extend ActiveSupport::Concern

        included do
          layout "decidim/application"

          def init_sessions!(options = {})
            session[:auth_attempt] = options
          end

          def auth_session
            (session[:auth_attempt].presence || {}).with_indifferent_access
          end
        end
      end
    end
  end
end
