require 'spec_helper'

module TemplateMatchers
  def contain(expected_text)
    simple_matcher("contain the following lines:\n#{expected_text}") do |path, matcher|
      if File.exist?(path)
        actual_text = IO.read(path)
        if actual_text.include?(expected_text)
          true
        else
          matcher.failure_message =
            "Expected to get the following text:\n#{expected_text}\nBut got:\n#{actual_text}"
          false
        end
      else
        matcher.failure_message = "File does not exist"
        false
      end
    end
  end

  def rails_command(command)
    FileUtils.cd RAILS_ROOT do
      output = `#{command} 2>&1`
      unless $? == 0
        violated "Command failed: #{command}\n#{output}"
      end
    end
  end
end

describe "script/generate effigy_view users create" do

  include TemplateMatchers

  before do
    @controller_name = 'users'
    @view_name = 'create'
    @view_class_name = 'UsersCreateView'
    rails_command "script/generate effigy_view --backtrace #{@controller_name} #{@view_name} 2>&1"
  end

  after do
    FileUtils.rm_f(view_path)
    FileUtils.rm_f(template_path)
  end

  it "should create a view file" do
    view_path.should contain("class #{@view_class_name} < Rails::Effigy::View")
    view_path.should contain("private")
    view_path.should contain("def transform")
    view_path.should contain(relative_template_path)
    view_path.should contain("end\nend")
  end

  it "should create a template file" do
    template_path.should contain("<h1>#{@view_class_name}</h1>")
    template_path.should contain("<p>Edit me at #{relative_template_path}</p>")
    template_path.should contain("<p>Edit my view at #{relative_view_path}</p>")
  end

  def view_path
    File.join(RAILS_ROOT, relative_view_path)
  end

  def relative_view_path
    File.join('app', 'views', @controller_name, "#{@view_name}.html.effigy")
  end

  def template_path
    File.join(RAILS_ROOT, relative_template_path)
  end

  def relative_template_path
    File.join('app', 'templates', @controller_name, "#{@view_name}.html")
  end

end

describe "script/generate effigy_view layouts narrow" do

  include TemplateMatchers

  before do
    @layout_name = 'narrow'
    @layout_class_name = 'NarrowLayout'
    rails_command "script/generate effigy_view --backtrace layouts #{@layout_name} 2>&1"
  end

  after do
    FileUtils.rm_f(view_path)
    FileUtils.rm_f(template_path)
  end

  it "should create a view file" do
    view_path.should contain("class #{@layout_class_name} < Rails::Effigy::View")
    view_path.should contain("private")
    view_path.should contain("def transform")
    view_path.should contain("html('body', content_for(:layout))")
    view_path.should contain(relative_template_path)
    view_path.should contain("end\nend")
  end

  it "should create a template file" do
    template_path.should contain("<html>")
    template_path.should contain("<body>")
    template_path.should contain("<p>Edit me at #{relative_template_path}</p>")
    template_path.should contain("<p>Edit my view at #{relative_view_path}</p>")
    template_path.should contain("</body>")
    template_path.should contain("</html>")
  end

  def view_path
    File.join(RAILS_ROOT, relative_view_path)
  end

  def relative_view_path
    File.join('app', 'views', 'layouts', "#{@layout_name}.html.effigy")
  end

  def template_path
    File.join(RAILS_ROOT, relative_template_path)
  end

  def relative_template_path
    File.join('app', 'templates', 'layouts', "#{@layout_name}.html")
  end

end
