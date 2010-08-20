gem 'nokogiri', '1.4.2'
require 'spec'
require 'spec/autorun'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze
RAILS_ROOT = File.join(PROJECT_ROOT, 'tmp', 'rails_root')

$: << File.join(PROJECT_ROOT, 'lib')

Dir[File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')].each { |file| require(file) }

Spec::Runner.configure do |config|
  config.include Matchers
end
