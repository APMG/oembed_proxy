# frozen_string_literal: true

module OembedProxy
  # Google Apps Fusiontable Map Fauxembeds
  class FusiontableMap
    FUSIONTABLE_REGEX = %r{^https://www\.google\.com/fusiontables(.*)$}

    def handles_url?(url)
      !(url =~ FUSIONTABLE_REGEX).nil?
    end

    def get_data(url, _other_params = {})
      return nil unless handles_url? url

      oembed = {}

      oembed['type'] = 'rich'
      oembed['version'] = '1.0'

      oembed['provider_name'] = 'Google Apps Fusion Tables'
      oembed['provider_url'] = 'https://www.google.com/drive/apps.html#fusiontables'

      oembed['html'] = '<iframe class="google-map" width="100%" height="500" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="' + url + '"></iframe>'
      oembed['width'] = 500
      oembed['height'] = 500

      oembed
    end
  end
end
