require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'cucumber/rake/task'

desc 'Default: run the specs, features, and metrics.'
task :default => [:spec, :cucumber, :metrics]

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

begin
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new do |t|
    t.spec_opts = ['--color', '--format', 'progress']
    t.libs = %w(spec)
    t.ruby_opts = ['-rrubygems']
  end

  task :spec => :rails_root

  desc "Run all specs individually to ensure that requires are correct"
  task :check_requires do
    Dir["spec/**/*_spec.rb"].each do |spec_file|
      system("spec -cfp #{spec_file}") or raise "Failed while running #{spec_file}"
    end
  end
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

eval("$specification = begin; #{IO.read('effigy.gemspec')}; end")
Rake::GemPackageTask.new($specification) do |package|
  package.need_zip = true
  package.need_tar = true
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.fork = true
  t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'progress')]
end
