When /^I add "([^"]*)" from this project as a dependency$/ do |gem_name|
  append_to_file('Gemfile', %{\ngem "#{gem_name}", :path => "#{PROJECT_ROOT}"})
end

When /^I add "([^"]*)" from rubygems as a dependency$/ do |gem_name|
  append_to_file('Gemfile', %{\ngem "#{gem_name}"})
end

When /^I (GET|POST|PUT|DELETE) (.*)$/ do |verb, path|
  @last_response = RailsServer.send(verb.downcase, path)
  announce_or_puts(@last_response) if @announce_stdout
end

When "I start the application" do
  in_current_dir do
    RailsServer.start(ENV['RAILS_PORT'])
  end
end

After do
  RailsServer.stop
end

When /^I configure my routes to allow global access$/ do
  steps %{
    When I write to "config/routes.rb" with:
      """
      Testapp::Application.routes.draw do
        match ':controller(/:action(/:id(.:format)))'
      end
      """
  }
end

Then /^the response should contain:$/ do |expected_source|
  @last_response.should include(expected_source)
end
