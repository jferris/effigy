module Effigy
  module Rails
    class View < ::Effigy::View
      def initialize(assigns, &layout_block)
        assigns.each do |name, value|
          instance_variable_set(name, value)
        end
        @layout_block = layout_block
      end

      protected

      def content_for(capture)
        @layout_block.call(capture)
      end
    end
  end
end
