# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'faraday/hypermedia/version'

Gem::Specification.new do |spec|
  spec.name          = "faraday-hypermedia"
  spec.version       = Faraday::Hypermedia::VERSION
  spec.authors       = ["Toru KAWAMURA"]
  spec.email         = ["tkawa@4bit.net"]

  spec.summary       = %q{Faraday middleware that supports hypermedia client}
  spec.description   = %q{Faraday middleware that supports hypermedia client}
  spec.homepage      = "https://github.com/tkawa/faraday-hypermedia"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 0.8.0"
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'http_link_header'
  spec.add_dependency 'faraday_collection_json'
  spec.add_dependency 'uri_template'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'faraday-detailed_logger'
  spec.add_development_dependency 'faraday-http-cache'
end
