# OembedProxy

[![Build Status](https://travis-ci.org/APMG/oembed_proxy.svg?branch=master)](https://travis-ci.org/APMG/oembed_proxy)

Library to manage multiple oEmbed providers, including officially supported oEmbeds, custom implemented "fauxembeds", and Embed.ly providers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oembed_proxy'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install oembed_proxy

## Short Example

```ruby
require 'oembed_proxy'

my_url = 'https://www.youtube.com/watch?v=yxMxQrX6dOQ'
handler = OembedProxy::Handler.new(
  OembedProxy::FirstParty.new,
  OembedProxy::AssociatedPress.new,
  OembedProxy::FusiontableMap.new,
  OembedProxy::GoogleDocument.new,
  OembedProxy::GoogleMapsengine.new,
  OembedProxy::GoogleSpreadsheet.new,
  OembedProxy::Tableau.new,
  OembedProxy::Embedly.new('myembedlykey'),
)
handler.handles_url?(my_url) # => true
handler.get_data(my_url) # =>
# {
#   "type" => "video",
#   "thumbnail_height" => 360,
#   "thumbnail_url" => "https://i.ytimg.com/vi/yxMxQrX6dOQ/hqdefault.jpg",
#   "provider_url" => "https://www.youtube.com/",
#   "thumbnail_width" => 480,
#   "title" => "Inside MPR News",
#   "author_url" => "https://www.youtube.com/user/AmericanPublicMedia",
#   "provider_name" => "YouTube",
#   "width" => 480,
#   "author_name" => "AmericanPublicMedia",
#   "height" => 270,
#   "version" => "1.0",
#   "html" => "<iframe width=\"480\" height=\"270\" src=\"https://www.youtube.com/embed/yxMxQrX6dOQ?feature=oembed\" frameborder=\"0\" allow=\"autoplay; encrypted-media\" allowfullscreen></iframe>"
# }
```

## Architecture

Each provider and the handler implement the following API:

* `#handles_url?(url)`
* `#get_data(url, other_params)`

The `#handles_url?(url)` method takes a URL and returns a boolean describing whether a given provider (or the composition of the registered providers in the case of the handler) supports the given URL.

The `#get_data(url, other_params)` method takes a URL and optional additional hash params (like `width:` and `height:`), and then returns a hash containing the oembed response.

### Handler

In addition to the two methods above, the handler also allows registration of provider classes. This can be done by providing a list of providers to the constructor:

```ruby
handler = OembedProxy::Handler.new([
  OembedProxy::FirstParty.new,
  OembedProxy::AssociatedPress.new,
])
```

Or this can be done by calling `#register(provider)`:

```ruby
handler = OembedProxy::Handler.new
handler.register OembedProxy::FirstParty.new
handler.register OembedProxy::AssociatedPress.new
```

Once providers have been registered, the `#handles_url?` and `#get_data` methods will work on the composition of the registered providers.

### Implementing your own providers

You are able to easily implement additional providers by creating an object which implements the `#handles_url?(url)` and `#get_data(url, other_params)` methods. Take a look at the existing provider classes for examples.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Before sending a pull request, you will want to run `bin/rubocop` to lint your work.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/APMG/oembed_proxy.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
