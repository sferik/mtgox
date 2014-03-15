# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mtgox/version'

Gem::Specification.new do |spec|
  spec.add_dependency  'faraday', ['~> 0.8', '< 0.10']
  spec.add_dependency  'json', ['~> 1.7', '>= 1.7.7']
  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.author        = 'Erik Michaels-Ober'
  spec.bindir        = 'bin'
  spec.description   = %q(Ruby wrapper for the Mt. Gox Trade API. Mt. Gox allows you to trade US Dollars (USD) for Bitcoins (BTC) or Bitcoins for US Dollars.)
  spec.email         = 'sferik@gmail.com'
  spec.executable    = 'btc'
  spec.files         = `git ls-files`.split("\n")
  spec.files         = %w[.yardopts CONTRIBUTING.md LICENSE.md README.md Rakefile mtgox.gemspec]
  spec.files        += Dir.glob('lib/**/*.rb')
  spec.files        += Dir.glob('spec/**/*')
  spec.licenses      = %w[MIT]
  spec.homepage      = 'https://github.com/sferik/mtgox'
  spec.name          = 'mtgox'
  spec.require_paths = %w[lib]
  spec.required_ruby_version = '>= 1.9.2'
  spec.required_rubygems_version = '>= 1.3.6'
  spec.summary       = %q(Ruby wrapper for the Mt. Gox Trade API)
  spec.test_files    = Dir.glob('spec/**/*')
  spec.version       = MtGox::VERSION
end
