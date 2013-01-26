# encoding: utf-8
require File.expand_path('../lib/mtgox/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'faraday', '~> 0.8'
  gem.add_dependency 'faraday_middleware', '~> 0.8'
  gem.add_dependency 'multi_json', '~> 1.3'
  gem.author      = "Erik Michaels-Ober"
  gem.description = %q{Ruby wrapper for the Mt. Gox Trade API. Mt. Gox allows you to trade US Dollars (USD) for Bitcoins (BTC) or Bitcoins for US Dollars.}
  gem.email       = 'sferik@gmail.com'
  gem.files       = `git ls-files`.split("\n")
  gem.homepage    = 'https://github.com/sferik/mtgox'
  gem.name        = 'mtgox'
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 1.9.2'
  gem.summary     = %q{Ruby wrapper for the Mt. Gox Trade API}
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version     = MtGox::Version.to_s
end
