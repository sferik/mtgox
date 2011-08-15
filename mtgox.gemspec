# encoding: utf-8
require File.expand_path('../lib/mtgox/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'faraday', '~> 0.7.4'
  gem.add_dependency 'faraday_middleware', '~> 0.7.0'
  gem.add_dependency 'multi_json', '~> 1.0.3'
  gem.add_development_dependency 'json', '~> 1.5'
  gem.add_development_dependency 'maruku', '~> 0.6'
  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'rspec', '~> 2.6'
  gem.add_development_dependency 'simplecov', '~> 0.4'
  gem.add_development_dependency 'webmock', '~> 1.6'
  gem.add_development_dependency 'yard', '~> 0.7'
  gem.author      = "Erik Michaels-Ober"
  gem.description = %q{Ruby wrapper for the Mt. Gox Trade API. Mt. Gox allows you to trade US Dollars (USD) for Bitcoins (BTC) or Bitcoins for US Dollars.}
  gem.email       = 'sferik@gmail.com'
  gem.files       = `git ls-files`.split("\n")
  gem.homepage    = 'https://github.com/sferik/mtgox'
  gem.name        = 'mtgox'
  gem.require_paths = ['lib']
  gem.summary     = %q{Ruby wrapper for the Mt. Gox Trade API}
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.version     = MtGox::VERSION.dup
end
