When /^I configure the rails 2 preinitializer to use bundler$/ do
  FileUtils.cp(File.join(TEMPLATE_ROOT, 'preinitializer.rb.template'),
               File.join(RAILS_ROOT, 'config', 'preinitializer.rb'))
  FileUtils.cp(File.join(TEMPLATE_ROOT, 'boot.rb.template'),
               File.join(RAILS_ROOT, 'config', 'boot.rb'))
end

When /^I generate a new rails 2 application$/ do
  @terminal.cd(TEMP_ROOT)
  @terminal.run("rails _2.3.8_ #{APP_NAME}")
end

