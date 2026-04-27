# frozen_string_literal: true

require "spec_helper"

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      describe VerificationCodeForm do
        subject { form }
        let(:form) do
          described_class.from_params(
            attributes
          )
        end

        let(:verification) { "0123" }
        let(:current_locale) { "en" }
        let(:organization) { create(:organization) }

        let(:attributes) do
          {
            verification:,
            current_locale:,
            organization:
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when there is no verification code" do
          let(:verification) { nil }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end
      end
    end
  end
end
