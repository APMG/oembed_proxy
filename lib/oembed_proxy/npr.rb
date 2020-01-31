# frozen_string_literal: true

require 'oembed_proxy/inactive_support'

module OembedProxy
  # NPR Fauxembed
  class Npr
    using InactiveSupport
    NPR_REGEX = %r{\Ahttps:\/\/(?:[a-z0-9-]+\.)+npr\.org\/.+}.freeze

    def handles_url?(url)
      !NPR_REGEX.match(url).nil?
    end

    def get_data(url, _other_params = {}) # rubocop:disable Metrics/MethodLength
      return nil unless handles_url? url

      escaped_url = url.gsub('"', '&quot;')
      {
        'type' => 'rich',
        'version' => '1.0',
        'provider_name' => 'NPR',
        'provider_url' => 'https://www.npr.org/',
        'html' => <<~HTML,
          <div class='sidechain-wrapper'>
            <side-chain src="#{escaped_url}"></side-chain>
          </div>
        HTML
      }
    end
  end
end
