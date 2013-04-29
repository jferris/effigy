module Effigy
  module Rails
    # Provides Rails-specific methods to Effigy views. Rather than
    # instantiating this class directly, it is recommended that you create view
    # and template files and allow {Effigy::Rails::TemplateHandler} to discover
    # and compile views.
    #
    # Instance variables from controller actions will be copied to the view.
    class View < ::Effigy::View

      # [ActionView::Base] the instance that is rendering this view. This
      #   instance is used to render partials and access other information about
      #   the action being rendered.
      attr_reader :action_view

      # The passed block will be called to access content captured by
      # content_for, such as layout contents.
      #
      # @param [ActionView::Base] action_view the instance that is rendering
      #   this view. See the action_view attribute.
      # @param [Hash] assigns a hash of instance variables to be copied. Names
      #   should include the "@" prefix.
      def initialize(action_view, assigns, &layout_block)
        @action_view = action_view
        assigns.each do |name, value|
          instance_variable_set(name, value)
        end
        @layout_block = layout_block
      end

      # Renders the given partial and returns the generated markup.
      #
      # @param [String] name the name of the partial to render, as given to
      #   ActionView::Base#render
      # @param [Hash] options
      # @option options [Hash] :locals a hash of extra variables to be assigned
      #   on the partial view
      # @return [String] the rendered contents from the partial
      def partial(name, options = {})
        options[:partial] = name
        action_view.render(options)
      end

      # Returns the captured content of the given name. Use "layout" as a name
      # to access the contents for the layout.
      #
      # @param [Symbol] capture the name of the captured content to return
      # @return [String] the captured content of the given name
      def content_for(capture)
        @layout_block.call(capture)
      end
    end
  end
end
