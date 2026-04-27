# frozen_string_literal: true

module Decidim
  module EphemeralAuthorizationHandler
    module Verification
      # Custom helpers, scoped to the ephemeral_authorization_handler engine.
      #
      module ApplicationHelper
        def phone_country_options(selected = nil)
          options_for_select(sorted_countries, selected)
        end

        def sorted_countries
          unsorted = ISO3166::Country.all.map do |c|
            next if Decidim::EphemeralAuthorizationHandler.default_countries&.include?(c.alpha2)

            generate_data(c)
          end
          unshift_defaults(unsorted)
        end

        private

        def generate_data(country)
          [
            "#{country.iso_short_name} (+#{country.country_code})",
            country.alpha2,
            { data: { flag_image: image_pack_path("media/images/#{country.alpha2.downcase}.svg") } }
          ]
        end

        def unshift_defaults(unsorted)
          Decidim::EphemeralAuthorizationHandler.default_countries&.reverse&.each do |alph2|
            country = ISO3166::Country.find_country_by_alpha2(alph2)
            unsorted.unshift(generate_data(country))
          end
          unsorted
        end
      end
    end
  end
end
