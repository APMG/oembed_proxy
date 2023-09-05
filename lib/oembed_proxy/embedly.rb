# frozen_string_literal: true

require 'oembed_proxy/api_fetcher'
require 'oembed_proxy/utility'

module OembedProxy
  # Embedly provider
  class Embedly
    EMBEDLY_URL = 'https://api.embed.ly/1/oembed'
    EMBEDLY_CONFIG_PATH = File.expand_path('../providers/embedly_patterns.def', __dir__)

    def initialize(embedly_key)
      # Import the expected embed.ly providers.
      @embedly_key = embedly_key
    end

    def get_data(url, other_params = {})
      other_params[:key] = @embedly_key
      api_fetcher.get_data(url, other_params)
    end

    def handles_url?(url)
      api_fetcher.handles_url?(url)
    end

    private

    def api_fetcher
      @api_fetcher ||= ApiFetcher.new(pattern_hash)
    end

    def pattern_hash
      @pattern_hash ||= File.readlines(EMBEDLY_CONFIG_PATH).to_h do |line|
        [Utility.clean_pattern(line), EMBEDLY_URL]
      end
    end
  end
end
