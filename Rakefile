require 'rubygems'
require 'rake'
require 'rake/gempackagetask'

desc 'Default: run the specs and metrics.'
task :default => [:spec, :metrics]

begin
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--color', '--format', 'progress']
    t.libs = %w(spec)
    t.ruby_opts = ['-rrubygems']
  end

  task :spec => :rails_root
rescue LoadError => exception
  puts "Missing dependencies for specs"
  task :spec do
    raise exception
  end
end

desc "Remove build files"
task :clean do
  %w(tmp pkg doc).each do |path|
    FileUtils.rm_rf(path)
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = %q{effigy}
    gem.version     = "0.1"
    gem.summary     = %q{Effigy provides a view and template framework without a templating language.}
    gem.description = %q{Define views in Ruby and templates in HTML. Avoid code interpolation or ugly templating languages. Use ids, class names, and semantic structures already present in your documents to produce content.}

    gem.files        = FileList['[A-Z]*', 'lib/**/*.rb', 'spec/**/*.rb']
    gem.require_path = 'lib'
    gem.test_files   = Dir[*['spec/**/*_spec.rb']]

    gem.authors = ["Joe Ferris"]
    gem.email   = %q{jferris@thoughtbot.com}

    gem.platform = Gem::Platform::RUBY

    gem.add_runtime_dependency 'nokogiri'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Missing dependencies for jeweler"
end

namespace :metrics do
  desc "Run reek"
  begin
    require 'reek/adapters/rake_task'
    task :reek do
      files = FileList['lib/**/*.rb', 'rails/**/*.rb'].to_a.join(' ')
      system("reek -q #{files}")
    end
  rescue LoadError => exception
    puts "Missing dependencies for metrics."
    task :reek do
      puts exception.inspect
    end
  end
end

desc "Run all metrics"
task :metrics => ['metrics:reek']

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb', 'rails/**/*.rb']
  end
rescue LoadError => exception
  puts "Missing dependencies for yard."
  task :yard do
    raise exception
  end
end
