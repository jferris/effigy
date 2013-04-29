require 'effigy/view'
require 'effigy/rails/view'
require 'effigy/rails/template_handler'

ActiveSupport.on_load(:action_view) do
  ActionView::Template.register_template_handler :effigy, Effigy::Rails::TemplateHandler
end

module Effigy
  # Rails-specific functionality.
  #
  # Effigy includes Rails generators for generating effigy view and template
  # files within Rails projects, as well as a Rails-specific view superclass
  # that provides functionality like assigns, layouts, and partials.
  #
  # Example:
  #
  # <pre>
  # # app/controllers/magic_controller.rb
  # class MagicController < ApplicationController
  #   def index
  #     @spell = 'hocus pocus'
  #   end
  # end
  # </pre>
  #
  # <pre>
  # # app/views/magic/index.html.effigy
  # class MagicIndexView < Effigy::Rails::View
  #   def transform
  #     text('h1', @spell)
  #   end
  # end
  # </pre>
  #
  # <pre>
  # # app/templates/magic/index.html
  # <h1>Spell name goes here</h1>
  # </pre>
  #
  # View this example in your browser and you'll see "hocus pocus."
  #
  # == Generators
  #
  # Example:
  #   ./script/generate effigy_view users new edit index
  #
  # This will generate Effigy views and templates for the "new," "edit," and
  # "index," actions of UsersController, such as
  # app/views/users/new.html.effigy, and app/templates/users/new.html.
  #
  # == Rendering Effigy views from Rails
  #
  # Effigy includes a Rails template handler, so you can render effigy views as normal.
  # Rendering the "index" action from "UsersController" will look for a
  # UsersIndexView class in app/views/users/index.html.effigy, and use it to
  # transform app/templates/users/index.html.
  #
  # == Effigy Rails views
  #
  # See {Effigy::Rails::View} for extra methods available to Rails views.
  module Rails
  end
end

