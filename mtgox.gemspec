# encoding: utf-8
require File.expand_path('../lib/mtgox/version', __FILE__)

Gem::Specification.new do |spec|
  spec.add_dependency 'faraday', '~> 0.8'
  spec.add_dependency 'faraday_middleware', '~> 0.8'
  spec.add_dependency 'multi_json', '~> 1.3'
  spec.author      = "Erik Michaels-Ober"
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
  spec.summary     = %q{Ruby wrapper for the Mt. Gox Trade API}
  spec.test_files  = Dir.glob("spec/**/*")
  spec.version     = MtGox::Version.to_s
end
