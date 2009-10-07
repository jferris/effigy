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

spec = Gem::Specification.new do |s|
  s.name        = %q{effigy}
  s.version     = "0.1"
  s.summary     = %q{Effigy provides a view and template framework without a templating language.}
  s.description = %q{Define views in Ruby and templates in HTML. Avoid code interpolation or ugly templating languages. Use ids, class names, and semantic structures already present in your documents to produce content.}

  s.files        = FileList['[A-Z]*', 'lib/**/*.rb', 'spec/**/*.rb']
  s.require_path = 'lib'
  s.test_files   = Dir[*['spec/**/*_spec.rb']]

  s.authors = ["Joe Ferris"]
  s.email   = %q{jferris@thoughtbot.com}

  s.platform = Gem::Platform::RUBY
end

Rake::GemPackageTask.new spec do |pkg|
  pkg.need_tar = true
  pkg.need_zip = true
end
