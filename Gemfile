source 'https://rubygems.org'

gem 'jruby-openssl', :platforms => :jruby
gem 'rake'
gem 'yard'

group :development do
  gem 'kramdown'
  gem 'pry'
  gem 'pry-debugger', :platforms => [:mri_19, :mri_20]
end

group :test do
  gem 'coveralls', :require => false
  gem 'rspec', '>= 2.11'
  gem 'simplecov', :require => false
  gem 'webmock'
end

platforms :rbx do
  gem 'rubinius-coverage', '~> 2.0'
  gem 'rubysl-base64', '~> 2.0'
  gem 'rubysl-bigdecimal', '~> 2.0'
  gem 'rubysl-net-http', '~> 2.0'
  gem 'rubysl-rexml', '~> 2.0'
  gem 'rubysl-singleton', '~> 2.0'
end

gemspec
