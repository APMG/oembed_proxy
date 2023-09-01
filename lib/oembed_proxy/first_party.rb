# frozen_string_literal: true

require 'yaml'
require 'cgi'
require 'net/http'
require 'json'

require 'oembed_proxy/utility'
require 'oembed_proxy/oembed_exception'

module OembedProxy
  # Handles all sites with officially supported oEmbed providers
  class FirstParty
    USER_AGENT = 'Ruby oEmbed Proxy'

    def initialize
      # Import the expected first party providers.
      @pattern_hash = {}

      yaml_hash = YAML.load_file(File.expand_path('../providers/first_party.yml', __dir__))
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

    def fetch(uri, times_recursed: 0)
      raise OembedException, '500 Internal Server Error' if times_recursed > MAX_REDIRECTS

      res = request_builder(uri)

      case res
      when Net::HTTPSuccess
        JSON[res.body]
      when Net::HTTPRedirection, Net::HTTPFound
        fetch(redirect_location(uri, res['location']), times_recursed: (times_recursed + 1))
      else
        raise OembedException, (ERROR_CLASS_MAPPING[res.class] || "Unknown response: #{res.class}")
      end
    rescue JSON::ParserError
      return nil # rubocop:disable Style/RedundantReturn
    end

    def redirect_location(original_uri, new_location)
      # Absolute URL
      return URI(new_location) if new_location.start_with?('http')

      # Relative path starting at root
      return URI("#{original_uri.scheme}://#{original_uri.host}#{new_location}") if new_location.start_with?('/')

      # Relative path starting at directory of original request (yuck)

      base_path = Pathname.new(original_uri.path).parent.to_s # Get the current directory
      base_path = '' if base_path == '/' # Special case, avoiding double slash in URL
      URI("#{original_uri.scheme}://#{original_uri.host}#{base_path}/#{new_location}")
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
