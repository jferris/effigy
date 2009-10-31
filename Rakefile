require 'rubygems'
require 'rake'
require 'rake/gempackagetask'

require 'spec/rake/spectask'

desc 'Default: run the specs and metrics.'
task :default => [:spec, :metrics]

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--color', '--format', 'progress']
  t.libs = %w(spec)
  t.ruby_opts = ['-rrubygems']
end

task :rails_root do
  rails_root = File.join('tmp', 'rails_root')
  unless File.exist?(rails_root)
    FileUtils.mkdir_p(File.dirname(rails_root))
    command = "rails #{rails_root}"
    output = `#{command} 2>&1`
    if $? == 0
      FileUtils.ln_s(FileUtils.pwd, File.join(rails_root, 'vendor', 'plugins'))
    else
      $stderr.puts "Command failed with status #{$?}:"
      $stderr.puts command
      $stderr.puts output
    end
  end
end


task :spec => :rails_root

desc "Remove build files"
task :clean do
  FileUtils.rm_rf('tmp')
  FileUtils.rm_rf('pkg')
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
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

begin
  require 'reek/adapters/rake_task'

  namespace :metrics do
    desc "Run reek"
    Reek::RakeTask.new do |t|
      t.source_files = FileList['lib/**/*.rb', 'rails/**/*.rb']
      t.fail_on_error = false
    end
  end

  desc "Run all metrics"
  task :metrics => ['metrics:reek']
rescue LoadError => e
  puts e.inspect
  puts "Missing dependencies for metrics."
end
