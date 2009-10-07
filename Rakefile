require 'rubygems'
require 'rake'
require 'rake/gempackagetask'

require 'spec/rake/spectask'

desc 'Default: run the specs.'
task :default => [:spec]

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--color', '--format', 'progress']
  t.libs = %w(spec)
  t.ruby_opts = ['-rrubygems']
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

