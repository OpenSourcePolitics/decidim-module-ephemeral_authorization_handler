# frozen_string_literal: true

require_relative "ephemeral_authorization_handler/verification"
require_relative "ephemeral_authorization_handler/version"

module Decidim
  # This namespace holds the logic of the `EphemeralAuthorizationHandler` component. This component
  # allows users to create ephemeral_authorization_handler in a participatory space.
  module EphemeralAuthorizationHandler
    include ActiveSupport::Configurable

    autoload :PhoneNumberFormatter, "decidim/ephemeral_authorization_handler/phone_number_formatter"

    # Default configuration digits to generate the auth code.
    config_accessor :auth_code_length do
      4
    end

    # The country or countries to be selected in country selection
    # during sms verification/authentication. The default is being set to nil
    config_accessor :default_countries do
      nil
    end

    config_accessor :code_ttl do
      5.minutes
    end
  end
end
