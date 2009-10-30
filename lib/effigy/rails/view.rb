module Effigy
  module Rails
    class View < ::Effigy::View
      def initialize(assigns)
        assigns.each do |name, value|
          instance_variable_set(name, value)
        end
      end
    end
  end
end
