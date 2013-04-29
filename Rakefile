require 'rake'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'reek/rake/task'
require 'yard'

desc 'Default: run the specs, features, and metrics.'
task :default => [:spec, :cucumber, :metrics]

RSpec::Core::RakeTask.new do |t|
end

desc "Run all specs individually to ensure that requires are correct"
task :check_requires do
  Dir["spec/**/*_spec.rb"].each do |spec_file|
    system("spec -cfp #{spec_file}") or raise "Failed while running #{spec_file}"
  end
end

namespace :metrics do
  desc "Run reek"
  task :reek do
    files = FileList['lib/**/*.rb', 'rails/**/*.rb'].to_a.join(' ')
    system("reek -q #{files}")
  end
end

desc "Run all metrics"
task :metrics => ['metrics:reek']

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'rails/**/*.rb']
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.fork = true
  t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'progress'), '--tags', '~@wip']
end
