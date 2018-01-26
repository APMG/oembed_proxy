module OembedProxy
  class GoogleDocument
    GOOGLE_DOCUMENT_REGEX = %r{https://docs\.google\.com/document(.*)}

    def handles_url?(url)
      !(url =~ GOOGLE_DOCUMENT_REGEX).nil?
    end

    def get_data(url, _other_params = {})
      return nil unless handles_url? url

      oembed = {}

      oembed['type'] = 'rich'
      oembed['version'] = '1.0'

      oembed['provider_name'] = 'Google Apps Documents'
      oembed['provider_url'] = 'https://docs.google.com/document/‎'

      oembed['html'] = '<iframe class="google-docs document" width="100%" height="500" frameborder="0" scrolling="yes" marginheight="0" marginwidth="0" src="' + url + '"></iframe>'
      oembed['width'] = 500
      oembed['height'] = 500

      oembed
    end
  end
end
