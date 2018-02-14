# frozen_string_literal: true

require 'yaml'
require 'cgi'

require 'oembed_proxy/utility'
require 'oembed_proxy/oembed_exception'

module OembedProxy
  # Handles all sites with officially supported oEmbed providers
  class FirstParty
    USER_AGENT = 'Ruby oEmbed Proxy'

    def initialize
      # Import the expected first party providers.
      @pattern_hash = {}

      yaml_hash = YAML.load_file('lib/providers/first_party.yml')
      yaml_hash.each_value do |hsh|
        hsh['pattern_list'].each do |pattern|
          regex = Utility.clean_pattern(pattern)
          @pattern_hash[regex] = hsh['endpoint']
        end
      end
    end

    def handles_url?(url)
      !find_endpoint(url).nil?
    end

    def get_data(url, other_params = {})
      endpoint = find_endpoint(url)
      return nil if endpoint.nil?

      uri = URI(endpoint)
      new_params = { url: url, format: 'json' }
      new_params.merge! other_params
      # Merge in existing params.
      new_params.merge! CGI.parse(uri.query) if uri.query
      uri.query = URI.encode_www_form(new_params)

      fetch(uri)
    end

    private

    ERROR_CLASS_MAPPING = {
      Net::HTTPBadRequest => '400 Bad Request',
      Net::HTTPUnauthorized => '401 Unauthorized',
      Net::HTTPForbidden => '403 Forbidden',
      Net::HTTPNotFound => '404 Not Found',
      Net::HTTPInternalServerError => '500 Internal Server Error',
      Net::HTTPNotImplemented => '501 Not Implemented',
      Net::HTTPServiceUnavailable => '503 Service Unavailable',
    }.freeze

    MAX_REDIRECTS = 10

    def fetch(uri, times_recursed: 0) # rubocop:disable Metrics/MethodLength
      raise OembedException, '500 Internal Server Error' if times_recursed > MAX_REDIRECTS

      res = request_builder(uri)

      case res
      when Net::HTTPSuccess
        JSON[res.body]
      when Net::HTTPMovedPermanently, Net::HTTPFound
        fetch(URI(res['location']), times_recursed: (times_recursed + 1))
      else
        raise OembedException, (ERROR_CLASS_MAPPING[res.class] || "Unknown response: #{res.class}")
      end
    rescue JSON::ParserError
      return nil
    end

    def request_builder(uri)
      req = Net::HTTP::Get.new(uri)
      req['User-Agent'] = USER_AGENT

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        http.request(req)
      end
    end

    def find_endpoint(url)
      @pattern_hash.each_key do |p|
        return @pattern_hash[p] if url.to_s.match(p)
      end

      # If all else fails, return nil.
      nil
    end
  end
end
