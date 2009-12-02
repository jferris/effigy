module Effigy
  module Rails
    class TemplateHandler < ActionView::TemplateHandler
      include ActionView::TemplateHandlers::Compilable

      def compile(view)
        @view = view
        load_view_class
        return <<-RUBY
          if @controller
            variables = @controller.instance_variable_names
            variables -= @controller.protected_instance_variables if @controller.respond_to?(:protected_instance_variables)
            assigns = variables.inject({}) do |hash, name|
              hash.update(name => @controller.instance_variable_get(name))
            end
            local_assigns.each do |name, value|
              assigns.update("@\#{name}" => value)
            end
          end
          view = #{view_class_name}.new(self, assigns) { |*names| yield(*names) }
          view.render(#{template_source.inspect})
        RUBY
      end

      def view_name
        @view.name
      end

      def base_path
        @view.base_path
      end

      def load_view_class
        load(@view.filename)
      end

      def view_class_name
        view_class_components.join('_').camelize.sub(/^Layouts/, '')
      end

      def view_class_components
        [base_path, view_name.sub(/^_/, ''), view_class_suffix]
      end

      def view_class_suffix
        if layout?
          'layout'
        elsif partial?
          'partial'
        else
          'view'
        end
      end

      def layout?
        base_path =~ /^layouts/
      end

      def partial?
        @view.name =~ /^_/
      end

      def template_source
        template_path = @view.load_path.path.sub(/\/views$/, '/templates')
        template_file_name = File.join(template_path, base_path, "#{view_name}.#{@view.format}")
        IO.read(template_file_name)
      end
    end
  end
end
