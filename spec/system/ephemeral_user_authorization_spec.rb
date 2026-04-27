# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/DescribeClass
describe "Ephemeral user authorization" do
  # rubocop:enable RSpec/DescribeClass
  include_context "with a component"

  let(:manifest_name) { "proposals" }
  let!(:organization) do
    create(:organization, available_authorizations: %w(ephemeral_authorization_handler))
  end

  let!(:proposal) { create(:proposal, component:) }
  let(:permissions) do
    { create: { authorization_handlers: { ephemeral_authorization_handler: {} } } }
  end

  let!(:component) do
    create(
      :proposal_component,
      :with_creation_enabled,
      manifest:,
      participatory_space:,
      permissions:
    )
  end

  before do
    switch_to_host(organization.host)
  end

  context "when not signed in" do
    before do
      visit main_component_path(component)
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::EphemeralAuthorizationHandler::Verification::BaseVerification).to receive(:generate_code).and_return("1234")
      # rubocop:enable RSpec/AnyInstance
    end

    context "and data does not match any user" do
      it "creates an ephemeral user and allows to create a new proposal" do
        ephemeral_users_count = Decidim::User.ephemeral.size
        ephemeral_authorizations_count = Decidim::Authorization.where(name: "ephemeral_authorization_handler").size
        click_on "New proposal"
        # on sms form
        expect(page).to have_content "Phone country"
        expect(page).to have_content "Phone number"
        fill_in "Phone number", with: "0123456789"
        click_on "Submit"
        # on verify_sms_code form
        expect(page).to have_content("Please enter the code:")
        fill_in "digit1", with: 1
        fill_in "digit2", with: 2
        fill_in "digit3", with: 3
        fill_in "digit4", with: 4
        # fill the hidden input that allows to verify code
        page.execute_script(<<~JS)
          document.querySelector('input[name="verification_code[verification]"]').value = '1234';
        JS
        click_on "Submit"
        expect(page).to have_content("Verification successful")
        expect(page).to have_content("Create new proposal")
        # new ephemeral user and new authorization created
        expect(Decidim::User.ephemeral.reload.size).to eq(ephemeral_users_count + 1)
        expect(Decidim::Authorization.where(name: "ephemeral_authorization_handler").reload.size).to eq(ephemeral_authorizations_count + 1)
      end
    end

    context "when the current user is ephemeral" do
      before do
        click_on "New proposal"
        ephemeral_verification_process
      end

      context "when data matches an existing ephemeral user" do
        it "the ephemeral user is able to recover its session" do
          ephemeral_users_count = Decidim::User.ephemeral.size
          ephemeral_authorizations_count = Decidim::Authorization.where(name: "ephemeral_authorization_handler").size
          fill_in :proposal_title, with: "This is a new proposal"
          fill_in :proposal_body, with: "The proposal includes a lot of ideas"
          click_on "Continue"

          expect(page).to have_content "Proposal successfully created. Saved as a Draft."

          accept_confirm do
            find("#main-bar [data-close]").click
          end
          sleep 2
          visit main_component_path(component)
          sleep 2
          click_on "New proposal"
          ephemeral_verification_process
          # retrieving draft proposal
          expect(page).to have_content "Edit proposal draft"
          expect(page).to have_field :proposal_title, with: "This is a new proposal"
          expect(page).to have_field :proposal_body, with: "The proposal includes a lot of ideas"
          # new ephemeral user created but no new authorization as it is transferred
          expect(Decidim::User.ephemeral.reload.size).to eq(ephemeral_users_count + 1)
          expect(Decidim::Authorization.where(name: "ephemeral_authorization_handler").reload.size).to eq(ephemeral_authorizations_count)
        end
      end
    end
  end

  context "when a regular user tries to create a new proposal" do
    # default code is +376
    let!(:first_authorization) { create(:authorization, :granted, user: ephemeral_user, name: "ephemeral_authorization_handler", unique_id: "+376123456789") }
    let!(:ephemeral_user) { create(:user, :ephemeral, organization:) }
    let!(:proposal) { create(:proposal, component:, users: [ephemeral_user]) }
    let(:user) { create(:user, :confirmed, organization:) }

    before do
      login_as user, scope: :user
      visit main_component_path(component)
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(Decidim::EphemeralAuthorizationHandler::Verification::BaseVerification).to receive(:generate_code).and_return("1234")
      # rubocop:enable RSpec/AnyInstance
      click_on "New proposal"
    end

    it "redirects to sms verification form" do
      expect(page).to have_content "Phone country"
      expect(page).to have_content "Phone number"
    end

    context "and verifies with the same data than an exisiting ephemeral user" do
      before do
        fill_in "Phone number", with: "0123456789"
        click_on "Submit"
        fill_in "digit1", with: 1
        fill_in "digit2", with: 2
        fill_in "digit3", with: 3
        fill_in "digit4", with: 4
        page.execute_script(<<~JS)
          document.querySelector('input[name="verification_code[verification]"]').value = '1234';
        JS
      end

      it "transfers the authorization" do
        expect { click_on "Submit" }.not_to change(Decidim::Authorization, :count)
        sleep 2
        expect(Decidim::Authorization.where(user: ephemeral_user)).to be_blank
        expect(first_authorization.reload.user).to eq(user)
      end

      it "transfers the authorship of the proposal" do
        expect(proposal.authors).to contain_exactly(ephemeral_user)
        click_on "Submit"
        sleep 2
        expect(proposal.reload.authors).to contain_exactly(user)
      end
    end
  end

  def ephemeral_verification_process
    fill_in "Phone number", with: "0123456789"
    click_on "Submit"
    fill_in "digit1", with: 1
    fill_in "digit2", with: 2
    fill_in "digit3", with: 3
    fill_in "digit4", with: 4
    page.execute_script(<<~JS)
      document.querySelector('input[name="verification_code[verification]"]').value = '1234';
    JS
    click_on "Submit"
  end
end
