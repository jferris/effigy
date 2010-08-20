Feature: Generate views in a Rails 2.3 application

  Background:
    When I generate a new rails 2 application
    And I configure the rails 2 preinitializer to use bundler
    And I save the following as "Gemfile"
      """
      source "http://rubygems.org"
      gem 'rails', '2.3.8'
      gem 'sqlite3-ruby', :require => 'sqlite3'
      gem 'effigy', :path => '../../', :require => 'effigy/rails'
      """
    When I run "bundle lock"

  Scenario: generate a controller view and template
    When I run "./script/generate effigy_view users create"
    Then the following should be saved as "app/views/users/create.html.effigy"
      """
      class UsersCreateView < Effigy::Rails::View
        private
        def transform
          # Apply transformations to the template file here:
          # text('h1', 'Hello')
          # Assigns from the action are available:
          # text('h1', @post.title)
          # Transformations will be applied to to the template file:
          # app/templates/users/create.html
          # See the documentation for more information.
        end
      end
      """
    Then the following should be saved as "app/templates/users/create.html"
      """
      <h1>UsersCreateView</h1>
      <p>Edit me at app/templates/users/create.html</p>
      <p>Edit my view at app/views/users/create.html.effigy</p>
      """

  Scenario: generate a layout view and template
    When I run "./script/generate effigy_view layouts narrow"
    Then the following should be saved as "app/views/layouts/narrow.html.effigy"
      """
      class NarrowLayout < Effigy::Rails::View
        private
        def transform
          # Apply transformations to the template file here:
          # text('h1', 'Hello')
          # Assigns from the action are available:
          # text('h1', @post.title)
          # Transformations will be applied to to the template file:
          # app/templates/layouts/narrow.html
          # See the documentation for more information.
          html('body', content_for(:layout))
        end
      end
      """
    Then the following should be saved as "app/templates/layouts/narrow.html"
      """
      <html>
        <body>
          <h1>NarrowLayout</h1>
          <p>Edit me at app/templates/layouts/narrow.html</p>
          <p>Edit my view at app/views/layouts/narrow.html.effigy</p>
        </body>
      </html>
      """

