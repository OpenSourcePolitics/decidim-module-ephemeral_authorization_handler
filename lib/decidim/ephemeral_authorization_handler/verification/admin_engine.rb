# frozen_string_literal: true

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      # This is the engine that runs on the public interface of `EphemeralAuthorizationHandler`.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::EphemeralAuthorizationHandler::Verification::Admin

        paths["db/migrate"] = nil
        paths["lib/tasks"] = nil

        # routes do
        # Add admin engine routes here
        # resources :ephemeral_authorization_handler do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "ephemeral_authorization_handler#index"
        # end

        def load_seed
          nil
        end
      end
    end
  end
end
