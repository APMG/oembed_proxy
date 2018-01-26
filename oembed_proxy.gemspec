
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "oembed_proxy/version"

Gem::Specification.new do |spec|
  spec.name          = "oembed_proxy"
  spec.version       = OembedProxy::VERSION
  spec.authors       = ["William Johnston"]
  spec.email         = ["wjohnston@mpr.org"]

  spec.summary       = 'Simple library to manage first party, embedly, and custom oembeds'
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://github.com/APMG/oembed_proxy'
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
