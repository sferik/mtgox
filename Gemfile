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
  gem 'rubysl'
end

gemspec
