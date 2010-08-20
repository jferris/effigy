PROJECT_ROOT  = File.expand_path(File.join(File.dirname(__FILE__), '..', '..')).freeze
TEMP_ROOT     = File.join(PROJECT_ROOT, 'tmp').freeze
APP_NAME      = 'testapp'.freeze
RAILS_ROOT    = File.join(TEMP_ROOT, APP_NAME).freeze
TEMPLATE_ROOT = File.join(PROJECT_ROOT, 'features', 'templates').freeze

Before do
  FileUtils.rm_rf(TEMP_ROOT)
  FileUtils.mkdir_p(TEMP_ROOT)
  @terminal = Terminal.new
end

When /^I save the following as "([^\"]*)"$/ do |path, string|
  FileUtils.mkdir_p(File.join(RAILS_ROOT, File.dirname(path)))
  File.open(File.join(RAILS_ROOT, path), 'w') { |file| file.write(string) }
end

When /^I run "([^\"]*)"$/ do |command|
  @terminal.cd(RAILS_ROOT)
  @terminal.run(command)
end

Then /^I should see "([^\"]*)"$/ do |expected_text|
  steps %{
    Then I should see:
    """
    #{expected_text}
    """
  }
end

Then /^I should see:$/ do |expected_text|
  unless @terminal.output.include?(expected_text)
    raise("Got terminal output:\n#{@terminal.output}\n\nExpected output:\n#{expected_text}")
  end
end

When /^I request "([^"]*)"$/ do |path|
  FileUtils.cp(File.join(TEMPLATE_ROOT, 'rails2_request.template'),
               File.join(RAILS_ROOT, 'script', 'request'))
  @terminal.run("ruby script/request #{path}")
end

