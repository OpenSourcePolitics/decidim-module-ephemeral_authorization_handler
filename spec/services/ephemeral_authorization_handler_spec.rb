# frozen_string_literal: true

require "spec_helper"

describe EphemeralAuthorizationHandler do
  subject do
    described_class.new(
      phone_number:,
      phone_country:
    )
  end

  let(:phone_number) { "+0640123422" }
  let(:phone_country) { "BR" }

  context "when everything is valid" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when phone number is nil" do
    let(:phone_number) { nil }

    it "is invalid" do
      expect(subject).to be_invalid
    end
  end

  context "when phone country is nil" do
    let(:phone_country) { nil }

    it "is invalid" do
      expect(subject).to be_invalid
    end
  end

  context "when invalid phone number format" do
    let(:phone_number) { "-1234567" }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end

  describe "unique_id" do
    context "when there is a phone number" do
      it "returns a formatted phone number as unique id" do
        expect(subject.unique_id).to eq("+55640123422")
      end
    end

    context "when there is a no phone number" do
      let(:phone_number) { nil }

      it "returns nil as unique id" do
        expect(subject.unique_id).to be_nil
      end
    end
  end

  describe "ephemeral" do
    it "returns true" do
      expect(described_class.ephemeral?).to be true
    end
  end
end
