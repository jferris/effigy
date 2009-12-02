module Effigy
  module Rails
    class View < ::Effigy::View

      # [ActionView::Base] the instance that is rendering this view
      attr_reader :action_view

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
      def partial(name, options = {})
        options[:partial] = name
        action_view.render(options)
      end

      protected

      def content_for(capture)
        @layout_block.call(capture)
      end
    end
  end
end
