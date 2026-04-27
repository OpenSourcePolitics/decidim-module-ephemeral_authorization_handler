# frozen_string_literal: true

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      class SendSmsVerification < BaseVerification
        def initialize(form, user)
          @form = form
          @user = user
        end

        def call
          result = send_sms_verification!

          if result
            broadcast(:ok, verification_code, expires_at, phone_number)
          else
            broadcast(:invalid)
          end
        end

        private

        attr_reader :form, :user

        delegate :current_organization, to: :form

        def send_sms_verification!
          gateway.deliver_code

          gateway.code
        rescue StandardError => e
          Rails.logger.error e.message

          false
        end

        def gateway
          @gateway ||=
            if Decidim.config.sms_gateway_service == "Decidim::Sms::Twilio::Gateway"
              Decidim.config.sms_gateway_service.constantize.new(phone_number, verification_code, organization: current_organization)
            elsif Decidim.config.sms_gateway_service.nil?
              Decidim::Verifications::Sms::ExampleGateway.new(phone_number, verification_code)
            else
              Decidim.config.sms_gateway_service.constantize.new(phone_number, verification_code)
            end
        end

        def phone_with_country_code(country_code, phone_number)
          PhoneNumberFormatter.new(phone_number:, iso_country_code: country_code).format
        end

        def phone_number
          @phone_number ||= phone_with_country_code(form.phone_country, form.phone_number)
        end
      end
    end
  end
end
