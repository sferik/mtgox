# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mtgox/version'

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', '~> 0.8'
  spec.add_dependency 'faraday_middleware', '~> 0.8'
  spec.add_dependency 'multi_json', '~> 1.3'
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.author      = "Erik Michaels-Ober"
  spec.cert_chain  = ['public_cert.pem']
  spec.description = %q{Ruby wrapper for the Mt. Gox Trade API. Mt. Gox allows you to trade US Dollars (USD) for Bitcoins (BTC) or Bitcoins for US Dollars.}
  spec.email       = 'sferik@gmail.com'
  spec.files       = `git ls-files`.split("\n")
  spec.files       = %w(.yardopts CHANGELOG.md CONTRIBUTING.md LICENSE.md README.md Rakefile mtgox.gemspec)
  spec.files      += Dir.glob("lib/**/*.rb")
  spec.files      += Dir.glob("spec/**/*")
  spec.homepage    = 'https://github.com/sferik/mtgox'
  spec.name        = 'mtgox'
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 1.9.2'
  spec.required_rubygems_version = '>= 1.3.6'
  spec.signing_key = '/Users/sferik/.gem/private_key.pem'
  spec.summary     = %q{Ruby wrapper for the Mt. Gox Trade API}
  spec.test_files  = Dir.glob("spec/**/*")
  spec.version     = MtGox::Version.to_s
end
