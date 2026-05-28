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
<<<<<<< HEAD
      Decidim::Env.new("DECIDIM_EPHEMERAL_AUTH_CODE_LENGTH", "4").to_i
=======
      4
>>>>>>> origin/master
    end

    # The country or countries to be selected in country selection
    # during sms verification/authentication. The default is being set to nil
    config_accessor :default_countries do
<<<<<<< HEAD
      Decidim::Env.new("DECIDIM_EPHEMERAL_AUTH_SMS_DEFAULT_COUNTRIES", nil).to_array
    end

    config_accessor :code_ttl do
      Decidim::Env.new("DECIDIM_EPHEMERAL_AUTH_CODE_TTL", "5").to_i.minutes
    end

    config_accessor :expires_in do
      Decidim::Env.new("DECIDIM_EPHEMERAL_AUTH_EXPIRES_IN", "30").to_i.days
    end

    config_accessor :renewable do
      Decidim::Env.new("DECIDIM_EPHEMERAL_AUTH_RENEWABLE", true).default_or_present_if_exists
    end

    config_accessor :time_between_renewals do
      Decidim::Env.new("DECIDIM_EPHEMERAL_AUTH_TIME_BETWEEN_RENEWALS", "1").to_i.days
=======
      nil
    end

    config_accessor :code_ttl do
      5.minutes
>>>>>>> origin/master
    end
  end
end
