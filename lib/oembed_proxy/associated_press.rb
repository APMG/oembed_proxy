# frozen_string_literal: true

module OembedProxy
  # Associated Press Interactives Fauxembed
  class AssociatedPress
    AP_REGEX = %r{\Ahttps?:\/\/(hosted.ap.org\/interactives|interactives.ap.org)\/.*}

    def handles_url?(url)
      !(url =~ AP_REGEX).nil?
    end

    def get_data(url, _other_params = {})
      return nil unless handles_url? url

      oembed = {}

      oembed['type'] = 'rich'
      oembed['version'] = '1.0'

      oembed['provider_name'] = 'Associated Press'
      oembed['provider_url'] = 'http://www.ap.org/'

      oembed['html'] = '<iframe class="ap-embed" width="100%" height="600" frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" src="' + url + '"></iframe>'
      oembed['width'] = 600
      oembed['height'] = 600

      oembed
    end
  end
end
