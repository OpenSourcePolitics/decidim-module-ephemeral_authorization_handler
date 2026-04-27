# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe EphemeralAuthorizationHandler do
    subject { described_class }

    it "has version" do
      expect(subject.version).to eq("1.0.0")
    end

    it "has decidim_version" do
      expect(subject.decidim_version).to eq("~> 0.31")
    end
  end
end
