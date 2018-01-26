module OembedProxy
  class GoogleMapsengine
    MAPSENGINE_REGEXES = [
      %r{https://mapsengine\.google\.com/map/(?:edit|view)\?mid=(.*)},
      %r{https://www\.google\.com/maps/d/edit\?mid=(.*)}
    ].freeze

    def handles_url?(url)
      !get_matching_regex(url).nil?
    end

    def get_data(url, _other_params = {})
      return nil unless handles_url? url

      oembed = {}

      oembed['type'] = 'rich'
      oembed['version'] = '1.0'

      oembed['provider_name'] = 'Google Maps Engine'
      oembed['provider_url'] = 'https://mapsengine.google.com/'

      mapsengine_id = url.match(get_matching_regex(url))[1]
      oembed['html'] = "<iframe class=\"google-map\" width=\"640\" height=\"480\" frameborder=\"0\" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" src=\"https://mapsengine.google.com/map/embed?mid=#{mapsengine_id}\"></iframe>"
      oembed['width'] = 500
      oembed['height'] = 500

      oembed
    end

    private

    def get_matching_regex(str)
      MAPSENGINE_REGEXES.each do |regex|
        return regex unless (str =~ regex).nil?
      end

      nil
    end
  end
end
