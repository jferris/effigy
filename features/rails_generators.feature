Feature: Generate views in a Rails application

  Background:
    When I run `rails new testapp`
    And I cd to "testapp"
    And I add "effigy" from this project as a dependency
    When I run `bundle install`

  @disable-bundler
  Scenario: generate a controller view and template
    When I run `bundle exec rails generate effigy:view users create`
    Then the file "app/views/users/create.html.effigy" should contain:
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
      Then the file "app/templates/users/create.html" should contain:
      """
      <h1>UsersCreateView</h1>
      <p>Edit me at app/templates/users/create.html</p>
      <p>Edit my view at app/views/users/create.html.effigy</p>
      """

  @disable-bundler
  Scenario: generate a layout view and template
    When I run `bundle exec rails generate effigy:view layouts narrow`
    Then the file "app/views/layouts/narrow.html.effigy" should contain:
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
    Then the file "app/templates/layouts/narrow.html" should contain:
      """
      <html>
        <body>
          <h1>NarrowLayout</h1>
          <p>Edit me at app/templates/layouts/narrow.html</p>
          <p>Edit my view at app/views/layouts/narrow.html.effigy</p>
        </body>
      </html>
      """

