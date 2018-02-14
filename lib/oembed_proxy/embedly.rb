# frozen_string_literal: true

require 'oembed_proxy/first_party'
require 'oembed_proxy/utility'

module OembedProxy
  # Embedly provider
  class Embedly < FirstParty
    EMBEDLY_URL = 'https://api.embed.ly/1/oembed'

    def initialize(embedly_key)
      # Import the expected embed.ly providers.
      @pattern_hash = {}
      @embedly_key = embedly_key

      File.open('lib/providers/embedly_patterns.def', 'r') do |f|
        f.each do |line|
          regex = Utility.clean_pattern(line)
          @pattern_hash[regex] = EMBEDLY_URL
        end
      end
    end

    def get_data(url, other_params = {})
      other_params[:key] = @embedly_key
      super
    end
  end
end
