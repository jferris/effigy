Feature: Integrate with Rails templates

  Background:
    When I generate a new rails app
    And I configure my routes to allow global access
    And I add "effigy" from this project as a dependency
    And I add "thin" from rubygems as a dependency
    When I run `bundle install --local`

  @disable-bundler
  Scenario: render a template and reference assigns
    When I write to "app/controllers/magic_controller.rb" with:
      """
      class MagicController < ApplicationController
        def index
          @spell = 'hocus pocus'
          render
        end
      end
      """
    When I write to "app/views/magic/index.html.effigy" with:
      """
      class MagicIndexView < Effigy::Rails::View
        def transform
          text('h1', @spell)
        end
      end
      """
    When I write to "app/templates/magic/index.html" with:
      """
      <h1 class="success">placeholder title</h1>
      """
    When I start the application
    And I GET /magic/index
    Then the response should contain:
      """
      <h1 class="success">hocus pocus</h1>
      """

  @disable-bundler
  Scenario: render a template within a layout
    When I write to "app/controllers/magic_controller.rb" with:
      """
      class MagicController < ApplicationController
        layout 'example'
      end
      """
    When I write to "app/views/magic/index.html.effigy" with:
      """
      class MagicIndexView < Effigy::Rails::View
      end
      """
    When I write to "app/templates/magic/index.html" with:
      """
      <h1 class="success">title</h1>
      """
    When I write to "app/views/layouts/example.html.effigy" with:
      """
      class ExampleLayout < Effigy::Rails::View
        def transform
          html('body', content_for(:layout))
        end
      end
      """
    When I write to "app/templates/layouts/example.html" with:
      """
      <html><body></body></html>
      """
    When I start the application
    And I GET /magic/index
    Then the response should contain:
      """
      <html><body><h1 class="success">title</h1></body></html>
      """

  @disable-bundler
  Scenario: render a partial
    When I write to "app/controllers/wand_controller.rb" with:
      """
      class WandController < ApplicationController
      end
      """
    When I write to "app/views/wand/index.html.effigy" with:
      """
      class WandIndexView < Effigy::Rails::View
        def transform
          replace_with('p', partial('spell', :locals  => { :name => 'hocus pocus' }))
        end
      end
      """
    When I write to "app/templates/wand/index.html" with:
      """
      <div>
        <h1 class="success">spell</h1>
        <p>placeholder</p>
      </div>
      """
    When I write to "app/views/wand/_spell.html.effigy" with:
      """
      class WandSpellPartial < Effigy::Rails::View
        def transform
          text('p', @name)
        end
      end
      """
    When I write to "app/templates/wand/_spell.html" with:
      """
      <p>put a spell on me</p>
      """
    When I start the application
    And I GET /wand/index
    Then the response should contain:
      """
      <div>
        <h1 class="success">spell</h1>
        <p>hocus pocus</p>
      </div>
      """
