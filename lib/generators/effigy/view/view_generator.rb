require 'generators/effigy/base'

module Effigy
  module Generators
    # Generates an Effigy view and template for a given controller and list of
    # actions.
    class ViewGenerator < Base
      argument :actions, :type => :array, :default => [], :banner => "action action"

      def effigy_directories
        empty_app_directories 'views', 'templates'
      end

      def effigy_views
        view_names.each do |view_name|
          effigy_view view_name
        end
      end

      private

      def controller_path
        File.join(class_path, file_name)
      end

      def view_names
        actions
      end

      def effigy_view(view_name)
        @view_path       = target_path('views', "#{view_name}.html.effigy")
        @template_path   = target_path('templates', "#{view_name}.html")
        @view_class_name = view_class_name(view_name)

        template template_for('view'), @view_path
        template template_for('template'), @template_path
      end

      def target_path(directory, file)
        File.join('app', directory, controller_path, file)
      end

      def view_class_name(view_name)
        prefix = "#{controller_path.camelize}#{view_name.camelize}"
        if layout?
          "#{prefix}Layout".sub(/^::Layouts(::)?/, '')
        else
          "#{prefix}View".sub(/^::/, '')
        end
      end

      def template_for(file)
        if layout?
          "layout_#{file}.erb"
        else
          "#{file}.erb"
        end
      end

      def layout?
        controller_path =~ /^\/layouts/
      end

      def empty_app_directories(*names)
        names.each do |name|
          empty_directory File.join('app', name, file_path)
        end
      end

    end
  end
end

