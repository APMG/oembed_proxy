require 'bundler/setup'

require 'pry'
require 'webmock/rspec'

require 'oembed_proxy'

require 'oembed_proxy/provider_contract_shared'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
