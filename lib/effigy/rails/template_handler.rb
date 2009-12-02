module Effigy
  module Rails
    # Adds hooks to Rails to discover Effigy views and templates.
    #
    # View files should be added to the app/views/<controller> directory with
    # an .effigy suffix. Template files should be added to
    # app/templates/<controller> with no suffix.
    #
    # For example, the view and template for PostsController#new would be
    # app/views/posts/new.html.effigy and app/templates/posts/new.html,
    # respectively.
    #
    # You can use the packaged generators to create these files.
    #
    # See {Effigy::Rails} for more information about generators.
    class TemplateHandler < ActionView::TemplateHandler
      include ActionView::TemplateHandlers::Compilable

      # Compiles the given view. Calls by ActionView when loading the view.
      # @return [String] Ruby code that can be evaluated to get the rendered
      #   contents of this view
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

      # @return [String] the name of the view, such as "index"
      def view_name
        @view.name
      end

      # @return [String] the path from the view root to the view file. For
      #   example, "RAILS_ROOT/app/views/users/index.html.effigy" would be
      #   "users."
      def base_path
        @view.base_path
      end

      # Loads the view class from the discovered view file. View classes should
      # be named after the controller and action, such as UsersIndexView.
      #
      # See {#view_class_name} for more information about class names.
      def load_view_class
        load(@view.filename)
      end

      # Generates a class name for this view. Normal views are prefixed with
      # the controller namd and suffixed with "View," such as "PostsEditView"
      # for app/views/posts/edit.html.effigy. Partials are prefixed with the
      # controller and suffixed with "Partial," such as "PostsPostPartial" for
      # app/views/posts/_post.html.effigy. Layouts are suffixed with "Layout,"
      # such as "ApplicationLayout" for
      # app/views/layouts/application.html.effigy.
      def view_class_name
        view_class_components.join('_').camelize.sub(/^Layouts/, '')
      end

      # @return [Array] the components that make up the class name for this view
      def view_class_components
        [base_path, view_name.sub(/^_/, ''), view_class_suffix]
      end

      # @return [String] the suffix for this view based on the type of view
      def view_class_suffix
        if layout?
          'layout'
        elsif partial?
          'partial'
        else
          'view'
        end
      end

      # @return [Boolean] true-ish if this view is a layout, false-ish otherwise
      def layout?
        base_path =~ /^layouts/
      end

      # @return [Boolean] true-ish if this view is a partial, false-ish otherwise
      def partial?
        @view.name =~ /^_/
      end

      # @return [String] the contents of the template file for this view
      def template_source
        template_path = @view.load_path.path.sub(/\/views$/, '/templates')
        template_file_name = File.join(template_path, base_path, "#{view_name}.#{@view.format}")
        IO.read(template_file_name)
      end
    end
  end
end
