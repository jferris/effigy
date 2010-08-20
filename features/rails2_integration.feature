Feature: Integrate with Rails 2.3

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

  Scenario: render a template a reference assigns
    When I save the following as "app/controllers/magic_controller.rb"
      """
      class MagicController < ApplicationController
        def index
          @spell = 'hocus pocus'
          render
        end
      end
      """
    When I save the following as "app/views/magic/index.html.effigy"
      """
      class MagicIndexView < Effigy::Rails::View
        def transform
          text('h1', @spell)
        end
      end
      """
    When I save the following as "app/templates/magic/index.html"
      """
      <h1 class="success">placeholder title</h1>
      """
    When I request "/magic/index"
    Then I should see:
      """
      <h1 class="success">hocus pocus</h1>
      """

  Scenario: render a template within a layout
    When I save the following as "app/controllers/magic_controller.rb"
      """
      class MagicController < ApplicationController
        layout 'application'
      end
      """
    When I save the following as "app/views/magic/index.html.effigy"
      """
      class MagicIndexView < Effigy::Rails::View
      end
      """
    When I save the following as "app/templates/magic/index.html"
      """
      <h1 class="success">title</h1>
      """
    When I save the following as "app/views/layouts/application.html.effigy"
      """
      class ApplicationLayout < Effigy::Rails::View
        def transform
          html('body', content_for(:layout))
        end
      end
      """
    When I save the following as "app/templates/layouts/application.html"
      """
      <html><body></body></html>
      """
    When I request "/magic/index"
    Then I should see:
      """
      <html><body><h1 class="success">title</h1></body></html>
      """

  Scenario: render a partial
    When I save the following as "app/controllers/wand_controller.rb"
      """
      class WandController < ApplicationController
      end
      """
    When I save the following as "app/views/wand/index.html.effigy"
      """
      class WandIndexView < Effigy::Rails::View
        def transform
          replace_with('p', partial('spell', :locals  => { :name => 'hocus pocus' }))
        end
      end
      """
    When I save the following as "app/templates/wand/index.html"
      """
      <div>
        <h1 class="success">spell</h1>
        <p>placeholder</p>
      </div>
      """
    When I save the following as "app/views/wand/_spell.html.effigy"
      """
      class WandSpellPartial < Effigy::Rails::View
        def transform
          text('p', @name)
        end
      end
      """
    When I save the following as "app/templates/wand/_spell.html"
      """
      <p>put a spell on me</p>
      """
    When I request "/wand/index"
    Then I should see:
      """
      <div>
        <h1 class="success">spell</h1>
        <p>hocus pocus</p>
      </div>
      """
