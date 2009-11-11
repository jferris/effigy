class EffigyViewGenerator < Rails::Generator::NamedBase

  def manifest
    record do |manifest|
      manifest.effigy_directories
      manifest.effigy_views view_names
    end
  end

  private

  def controller_path
    File.join(class_path, file_name)
  end

  def view_names
    actions
  end

  def record
    EffigyViewManifest.new(self, controller_path) { |manifest| yield manifest }
  end

  class EffigyViewManifest < Rails::Generator::Manifest
    def initialize(generator, controller_path)
      @controller_path = controller_path
      super(generator)
    end

    def effigy_directories
      directory File.join('app', 'views', @controller_path)
      directory File.join('app', 'templates', @controller_path)
    end

    def effigy_views(view_names)
      view_names.each do |view_name|
        effigy_view view_name
      end
    end

    def effigy_view(view_name)
      view_path     = File.join('app', 'views', @controller_path, "#{view_name}.html.effigy")
      template_path = File.join('app', 'templates', @controller_path, "#{view_name}.html")
      assigns       = { :view_class_name => view_class_name(view_name),
                        :template_path   => template_path,
                        :view_path       => view_path }

      template template_for('view'),
               view_path,
               :assigns => assigns

      template template_for('template'),
               template_path,
               :assigns => assigns
    end

    private

    def view_class_name(view_name)
      prefix = "#{@controller_path.camelize}#{view_name.camelize}"
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
      @controller_path =~ /^\/layouts/
    end
  end

end
