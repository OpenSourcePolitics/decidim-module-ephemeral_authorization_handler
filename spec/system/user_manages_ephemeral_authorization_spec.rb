# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/DescribeClass
describe "User manages ephemeral authorization" do
  # rubocop:enable RSpec/DescribeClass
  let!(:organization) do
    create(:organization, available_authorizations: ["ephemeral_authorization_handler"])
  end

  let(:user) { create(:user, :confirmed) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit decidim.account_path
    click_on "Authorizations"
  end

  it "displays the authorization item" do
    within ".authorizations-list" do
      expect(page).to have_content("Ephemeral Authorization via SMS")
      expect(page).to have_content("Get verified by entering a code sent to your mobile phone")
    end
  end

  context "when accessing ephemeral authorization" do
    before do
      click_on "Ephemeral Authorization via SMS"
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::EphemeralAuthorizationHandler::Verification::BaseVerification).to receive(:generate_code).and_return("1234")
      # rubocop:enable RSpec/AnyInstance
    end

    it "displays sms form" do
      expect(page).to have_content "Phone country"
      expect(page).to have_content "Phone number"
    end

    it "allows user to fill sms form and verify_sms_code, and redirect to authorizations page" do
      fill_in "Phone number", with: "0123456789"
      click_on "Submit"

      expect(page).to have_content("Please enter the code:")
      find('input[name="digit1"]').set(1)
      find('input[name="digit2"]').set(2)
      find('input[name="digit3"]').set(3)
      find('input[name="digit4"]').set(4)
      # fill the hidden input that allows to verify code
      page.execute_script(<<~JS)
        document.querySelector('input[name="verification_code[verification]"]').value = '1234';
      JS
      click_on "Submit"
      expect(page).to have_content("Participant settings - Authorizations")
      expect(page).to have_content("Verification successful")
    end

    it "displays an error message if verification code is false" do
      fill_in "Phone number", with: "0123456789"
      click_on "Submit"

      expect(page).to have_content("Please enter the code:")
      find('input[name="digit1"]').set(0)
      find('input[name="digit2"]').set(0)
      find('input[name="digit3"]').set(0)
      find('input[name="digit4"]').set(0)
      # fill the hidden input that allows to verify code
      page.execute_script(<<~JS)
        document.querySelector('input[name="verification_code[verification]"]').value = '0000';
      JS
      click_on "Submit"
      expect(page).to have_content("The code entered is not valid")
    end
  end
end
