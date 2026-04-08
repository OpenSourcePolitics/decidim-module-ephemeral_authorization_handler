# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module EphemeralAuthorizationHandler
    # This is the engine that runs on the public interface of ephemeral_authorization_handler.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::EphemeralAuthorizationHandler

      routes do
        # Add engine routes here
        # resources :ephemeral_authorization_handler
        # root to: "ephemeral_authorization_handler#index"
      end

      initializer "EphemeralAuthorizationHandler.shakapacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "EphemeralAuthorizationHandler.data_migrate", after: "decidim_core.data_migrate" do
        DataMigrate.configure do |config|
          config.data_migrations_path << root.join("db/data").to_s
        end
      end
    end
  end
end
