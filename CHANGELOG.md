# oEmbed Proxy Changelog

## [`0.2.6`] (2020-12-15)

[`0.2.6`]: https://github.com/APMG/oembed_proxy/compare/v0.2.5...v0.2.6

* Add https to youtube and vimeo provider urls.

## [`0.2.5`] (2020-07-30)

[`0.2.5`]: https://github.com/APMG/oembed_proxy/compare/v0.2.4...v0.2.5

This release contains no code changes.
The gem published for 0.2.4 contained files missing read-permissions
for "group" and "other", which could prevent loading of those files
in environments where gems are installed by a user who is not the
effective user at gem load time.

* Fix file permissions on `lib/oembed_proxy/*.rb` for published gem.

## [`0.2.4`] (2020-07-30)

[`0.2.4`]: https://github.com/APMG/oembed_proxy/compare/v0.2.3...v0.2.4

* Move poll.fm from Embed.ly to First Party.

## [`0.2.3`] (2020-02-03)

[`0.2.3`]: https://github.com/APMG/oembed_proxy/compare/v0.2.2...v0.2.3

* Move Facebook from Embed.ly to First Party.

## [`0.2.2`] (2020-01-31)

[`0.2.2`]: https://github.com/APMG/oembed_proxy/compare/v0.2.0...v0.2.2

*Note: The 0.2.1 release had critical bugs and should not be used.*

* Add a new Fauxembed for NPR Sidechain embeds.

## [`0.2.0`] (2020-01-16)

[`0.2.0`]: https://github.com/APMG/oembed_proxy/compare/v0.1.3...v0.2.0

* Add Datawrapper to supported embed.ly embeds
* Updated Bundler requirement
* Rubocop upgrade to 0.78
* Modernizing Ruby versions in build

## [`0.1.3`] (2018-04-24)

[`0.1.3`]: https://github.com/APMG/oembed_proxy/compare/v0.1.2...v0.1.3

* Add another regex pattern to the embedly list to allow for quizzes

## [`0.1.2`] (2018-03-29)

[`0.1.2`]: https://github.com/APMG/oembed_proxy/compare/v0.1.1...v0.1.2

* Add support for Radio Public by adding it to the embed.ly providers list.

## [`0.1.1`] (2018-02-27)

[`0.1.1`]: https://github.com/APMG/oembed_proxy/compare/v0.1.0...v0.1.1

* Fix file references for first party and embedly providers.

## [`0.1.0`] (2018-02-27)

[`0.1.0`]: https://github.com/APMG/oembed_proxy/compare/d33988df08b49237183155d3a4855d76e5cf7c2b...v0.1.0

* Initial open source release
