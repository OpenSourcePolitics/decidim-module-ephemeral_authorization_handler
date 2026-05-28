# frozen_string_literal: true

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      class AuthorizationsController < ::Decidim::ApplicationController
        include FormFactory
        include EphemeralAuthorizationHandlerConcern
        include Decidim::Verifications::Renewable

        helper Decidim::EphemeralAuthorizationHandler::Verification::ApplicationHelper

        def new
          return redirect_to decidim_ephemeral_authorization_handler.sms_authorization_path if user_signed_in?

          action = current_user.extended_data.dig("onboarding", "action")
          if requested_component.permissions[action]["authorization_handlers"].keys.include?("ephemeral_authorization_handler")
            redirect_to decidim_ephemeral_authorization_handler.sms_authorization_path
          else
            redirect_to decidim_verifications.onboarding_pending_authorizations_path
          end
        end

        def renew
          redirect_to decidim_ephemeral_authorization_handler.sms_authorization_path
        end

        def sms
          @form = form(Decidim::EphemeralAuthorizationHandler::Verification::SmsCodeForm).instance
        end

        def verify_sms_code
          @form = form(::Decidim::EphemeralAuthorizationHandler::Verification::VerificationCodeForm).instance
        end

        def verify
          form = form(Decidim::EphemeralAuthorizationHandler::Verification::SmsCodeForm).from_params(params)

          SendSmsVerification.call(form, current_user) do
            on(:ok) do |result, expires_at, formatted_phone_number|
              init_sessions!({ code: result, expires_at: expires_at, formatted_phone_number:, phone_number: params["sms_code"]["phone_number"],
                               phone_country: params["sms_code"]["phone_country"], strategy: :sms })
              flash[:notice] = I18n.t("success", scope: "decidim.ephemeral_authorization_handler.sms", phone_number: phone_number)
              redirect_to decidim_ephemeral_authorization_handler.verify_sms_code_authorization_path
            end

            on(:invalid) do |_error_code|
              flash.now[:alert] = I18n.t("error", scope: "decidim.ephemeral_authorization_handler.sms")
              redirect_to decidim_ephemeral_authorization_handler.root_path
            end
          end
        end

        def edit; end

        def verify_submitted_code
          return redirect_to decidim_ephemeral_authorization_handler.new_authorization_path if auth_session.blank?

          if auth_session[:code] == params[:verification_code][:verification]
            # if there is a duplicated authorization associated
            # to an ephemeral user and the current user is also ephemeral
            # the session is transferred to the user  with the existing authorization
            if transferable_user?
              handler.user = authorization.user
              Authorization.create_or_update_from(handler)
              handler.user.update(last_sign_in_at: Time.current, deleted_at: nil)
              sign_out(current_user)
              sign_in(handler.user)
<<<<<<< HEAD
              redirect_to handler.user.extended_data.dig("onboarding", "redirect_path") || decidim_verifications.authorizations_path
=======
              redirect_to handler.user.extended_data.dig("onboarding", "redirect_path")
>>>>>>> origin/master
            elsif transferable_handler?
              # if there is an existing authorization that can be transferred
              handler.user = current_user
              transfer = proceed_transfer(authorization, handler)
              handle_transfer(transfer)
            else
              # create Authorization
              new_authorization = Decidim::Authorization.find_or_initialize_by(
                user: current_user,
                name: "ephemeral_authorization_handler"
              )
              new_authorization.attributes = {
                granted_at: Time.current,
                unique_id: auth_session[:formatted_phone_number],
                metadata: { phone_number: auth_session[:formatted_phone_number] },
                verification_metadata: {},
                verification_attachment: nil
              }
              new_authorization.save!
              init_sessions!
              flash[:notice] = I18n.t("success", scope: "decidim.ephemeral_authorization_handler.verification.authorizations.verify_sms_code")
              # redirect for ephemeral user or signed_in user
              redirect_to current_user.extended_data.dig("onboarding", "redirect_path") || decidim_verifications.authorizations_path
            end
          else
            # invalid code
            flash[:alert] = I18n.t("error", scope: "decidim.ephemeral_authorization_handler.verification.authorizations.verify_sms_code")
            redirect_to decidim_ephemeral_authorization_handler.verify_sms_code_authorization_path
          end
        end

        def transferable_user?
          authorization.present? && [authorization.user, current_user].all?(&:ephemeral?)
        end

        def transferable_handler?
          authorization.present? && (authorization.user.deleted? || authorization.user.ephemeral?)
        end

        def proceed_transfer(authorization, handler)
          authorization.transfer!(handler)
        rescue Decidim::AuthorizationTransfer::DisabledError
          Decidim::Verifications::AuthorizeUser.register_conflict
          redirect_to decidim_ephemeral_authorization_handler.verify_sms_code_authorization_path
        end

        def handle_transfer(transfer)
          if transfer
            message = t("authorizations.create.success", scope: "decidim.verifications")
            if transfer.records.any?
              flash[:html_safe] = true
              message = <<~HTML
                <p>#{CGI.escapeHTML(message)}</p>
                <p>#{CGI.escapeHTML(t("authorizations.create.transferred", scope: "decidim.verifications"))}</p>
                #{transfer.presenter.records_list_html}
              HTML
            end

            flash[:notice] = message
<<<<<<< HEAD
            redirect_to transfer.user.extended_data.dig("onboarding", "redirect_path") || decidim_verifications.authorizations_path
=======
            redirect_to transfer.user.extended_data["onboarding"]["redirect_path"]
>>>>>>> origin/master
          else
            flash[:alert] = I18n.t("error", scope: "decidim.ephemeral_authorization_handler.verification.authorizations.verify_sms_code")
            redirect_to decidim_ephemeral_authorization_handler.verify_sms_code_authorization_path
          end
        end

        def authorization
          Decidim::Authorization.find_by(
            user: Decidim::User.where.not(id: current_user.id).where(organization: current_user.organization),
            name: "ephemeral_authorization_handler",
            unique_id: auth_session[:formatted_phone_number]
          )
        end

        private

        def handler
          @handler ||= ::EphemeralAuthorizationHandler.new(phone_number: auth_session[:phone_number], phone_country: auth_session[:phone_country])
        end

        def requested_component
          path = current_user.extended_data.dig("onboarding", "redirect_path")
          id = URI.parse(path).path.match(%r{/f/(\d+)/})&.captures&.first
          Decidim::Component.find(id)
        end
      end
    end
  end
end
