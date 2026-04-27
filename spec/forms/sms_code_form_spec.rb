# frozen_string_literal: true

require "spec_helper"

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      describe SmsCodeForm do
        subject { form }
        let(:form) do
          described_class.from_params(
            attributes
          )
        end

        let(:phone_number) { "0123456789" }
        let(:phone_country) { "BR" }
        let(:attributes) do
          {
            phone_number:,
            phone_country:
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when there is no phone number" do
          let(:phone_number) { nil }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "when there is no phone country" do
          let(:phone_country) { nil }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end

        context "with invalid phone number format" do
          let(:phone_number) { "-1234567" }

          it "is invalid" do
            expect(subject).not_to be_valid
          end
        end
      end
    end
  end
end
