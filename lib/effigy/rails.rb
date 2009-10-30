require 'action_view'
require 'effigy/view'
require 'effigy/rails/view'
require 'effigy/rails/template_handler'

ActionView::Template.register_template_handler :effigy, Effigy::Rails::TemplateHandler
