require 'yaml'
require 'cgi'

require 'oembed_proxy/utility'
require 'oembed_proxy/oembed_exception'

module OembedProxy
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
      new_params = {
        url: url,
        format: 'json'
      }
      new_params.merge! other_params
      # Merge in existing params.
      new_params.merge! CGI.parse(uri.query) if uri.query
      uri.query = URI.encode_www_form(new_params)

      fetch(uri)
    end

    private

    def fetch(uri, times_recursed: 0)
      req = Net::HTTP::Get.new(uri)
      req['User-Agent'] = USER_AGENT
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        http.request(req)
      end

      # TODO: This doesn't follow redirects.

      case res
      when Net::HTTPSuccess
        begin
          return JSON[res.body]
        rescue StandardError
          # Invalid JSON
          return nil
        end
      when Net::HTTPMovedPermanently, Net::HTTPFound
        raise OembedException, '500 Internal Server Error' if times_recursed > 10
        fetch(URI(res['location']), times_recursed: (times_recursed + 1))
      when Net::HTTPBadRequest
        raise OembedException, '400 Bad Request'
      when Net::HTTPUnauthorized
        raise OembedException, '401 Unauthorized'
      when Net::HTTPForbidden
        raise OembedException, '403 Forbidden'
      when Net::HTTPNotFound
        raise OembedException, '404 Not Found'
      when Net::HTTPInternalServerError
        raise OembedException, '500 Internal Server Error'
      when Net::HTTPNotImplemented
        raise OembedException, '501 Not Implemented'
      when Net::HTTPServiceUnavailable
        raise OembedException, '503 Service Unavailable'
      else
        raise OembedException, 'Unknown response: ' + res.class.to_s
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
