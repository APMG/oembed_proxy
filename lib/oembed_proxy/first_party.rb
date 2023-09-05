# frozen_string_literal: true

require 'yaml'
require 'cgi'
require 'net/http'
require 'json'

require 'oembed_proxy/api_fetcher'
require 'oembed_proxy/utility'

module OembedProxy
  # Handles all sites with officially supported oEmbed providers
  class FirstParty
    USER_AGENT = 'Ruby oEmbed Proxy'
    FIRST_PARTY_CONFIG_PATH = File.expand_path('../providers/first_party.yml', __dir__)

    def handles_url?(url)
      api_fetcher.handles_url?(url)
    end

    def get_data(url, other_params = {})
      api_fetcher.get_data(url, other_params)
    end

    private

    def api_fetcher
      @api_fetcher ||= ApiFetcher.new(pattern_hash)
    end

    def pattern_hash
      # Each value in the YAML hash is an end point and an array of patterns.
      # We want to map each pattern in the array to the endpoint and return a list
      # of all mappings present in the file.
      @pattern_hash ||= YAML.load_file(FIRST_PARTY_CONFIG_PATH).each_value.reduce({}) do |pat_hash, hsh|
        pat_hash.merge(hsh['pattern_list'].to_h do |pattern|
          [Utility.clean_pattern(pattern), hsh['endpoint']]
        end)
      end
    end
  end
end
