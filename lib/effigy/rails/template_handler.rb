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
          end
          #{view_class_name}.new(assigns).render(#{template_source.inspect})
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
        [base_path, view_name, 'view'].join('_').camelize
      end

      def template_source
        template_path = @view.load_path.path.sub(/\/views$/, '/templates')
        template_file_name = File.join(template_path, base_path, "#{view_name}.#{@view.format}")
        IO.read(template_file_name)
      end
    end
  end
end
