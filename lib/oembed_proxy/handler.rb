# frozen_string_literal: true

module OembedProxy
  # Generic composing handler
  class Handler
    def initialize(providers = [])
      @registered_providers = providers
    end

    def register(provider)
      @registered_providers << provider
    end

    def handles_url?(url)
      !provider_for_url(url).nil?
    end

    def get_data(url, other_params = {})
      provider = provider_for_url(url)
      return provider.get_data(url, other_params) unless provider.nil?
    end

    private

    def provider_for_url(url)
      # TODO: Switch to #find
      @registered_providers.select { |p| p.handles_url? url }.first
    end
  end
end
