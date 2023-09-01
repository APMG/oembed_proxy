# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :development do
  gem 'bundler', '~> 2.0'
  gem 'rake'
  gem 'rspec'
  gem 'rubocop', '~> 1.0'
end

group :test do
  gem 'simplecov'
  gem 'webmock'
end

group :development, :test do
  gem 'pry'
  gem 'pry-byebug'
end

# Specify your gem's dependencies in oembed_proxy.gemspec
gemspec
