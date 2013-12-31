require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :test => :spec

require 'yard'
namespace :doc do
  YARD::Rake::YardocTask.new do |task|
    task.files   = %w[LICENSE.md lib/**/*.rb]
    task.options = [
      '--tag', 'authenticated:Requires Authentication',
      '--markup', 'markdown',
    ]
  end
end

begin
  require 'rubocop/rake_task'
  Rubocop::RakeTask.new
rescue LoadError
  task :rubocop do
    $stderr.puts 'Rubocop is disabled'
  end
end

task :default => [:spec, :rubocop]
