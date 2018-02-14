# frozen_string_literal: true

module OembedProxy
  # Google Maps Engine Fauxembed
  class GoogleMapsengine
    MAPSENGINE_REGEXES = [
      %r{https://mapsengine\.google\.com/map/(?:edit|view)\?mid=(.*)},
      %r{https://www\.google\.com/maps/d/edit\?mid=(.*)},
    ].freeze

    def handles_url?(url)
      !get_matching_regex(url).nil?
    end

    def get_data(url, _other_params = {})
      return nil unless handles_url? url

      {
        'type' => 'rich',
        'version' => '1.0',
        'provider_name' => 'Google Maps Engine',
        'provider_url' => 'https://mapsengine.google.com/',
        'html' => "<iframe class=\"google-map\" width=\"640\" height=\"480\" frameborder=\"0\" scrolling=\"no\" marginheight=\"0\" marginwidth=\"0\" src=\"https://mapsengine.google.com/map/embed?mid=#{url.match(get_matching_regex(url))[1]}\"></iframe>",
        'width' => 500,
        'height' => 500,
      }
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
