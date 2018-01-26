source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :development do
  gem 'rubocop'
end

group :test do
  gem 'webmock'
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
end

# Specify your gem's dependencies in oembed_proxy.gemspec
gemspec
