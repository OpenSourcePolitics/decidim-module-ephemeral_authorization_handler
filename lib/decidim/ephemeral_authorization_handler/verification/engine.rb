# frozen_string_literal: true

require "rails"
require "decidim/core"
require "countries"

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      # This is the engine that runs on the public interface of ephemeral_authorization_handler.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::EphemeralAuthorizationHandler::Verification

        routes do
          resource :authorizations, only: [:new, :edit], as: :authorization do
            get :sms, to: "authorizations#sms"
            get :verify_sms_code, to: "authorizations#verify_sms_code"
            post :verify, to: "authorizations#verify"
            post :verify_submitted_code, to: "authorizations#verify_submitted_code"
            get :renew, on: :collection
          end

          root to: "authorizations#new"
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
end
