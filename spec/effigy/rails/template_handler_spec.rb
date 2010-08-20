require 'spec_helper'

require File.join(RAILS_ROOT, 'config', 'environment')
require File.join(PROJECT_ROOT, 'rails', 'init')
require 'action_view/test_case'
require 'nokogiri'

describe "a controller with an effigy view and template" do
  before do
    @files = []
  end

  after do
    @files.each do |file|
      FileUtils.rm(file)
    end
  end

  def create_rails_file(relative_path, contents)
    absolute_path = File.join(RAILS_ROOT, relative_path)
    FileUtils.mkdir_p(File.dirname(absolute_path))
    File.open(absolute_path, 'w') { |file| file.write(contents) }
    @files << absolute_path
    absolute_path
  end

  def create_rails_source_file(relative_path, contents)
    load create_rails_file(relative_path, contents)
  end

  def render(controller, action = :index)
    @controller = controller
    class << @controller
      include ActionController::TestCase::RaiseActionExceptions
    end
    @request  ||= ActionController::TestRequest.new
    @response ||= ActionController::TestResponse.new
    get :index
    @response
  end

  include ActionController::TestProcess

  it "should use the view to render the template" do
    create_rails_source_file 'app/controllers/magic_controller.rb', <<-RUBY
      class MagicController < ApplicationController
        def index
          @spell = 'hocus pocus'
          render
        end
      end
    RUBY

    create_rails_file 'app/views/magic/index.html.effigy', <<-RUBY
      class MagicIndexView < Effigy::Rails::View
        def transform
          text('h1', @spell)
        end
      end
    RUBY

    create_rails_file 'app/templates/magic/index.html', <<-HTML
      <h1 class="success">placeholder title</h1>
    HTML

    response = render(MagicController.new)

    response.should be_success
    response.rendered[:template].to_s.should == 'magic/index.html.effigy'
    assigns(:spell).should_not be_nil
    response.body.should have_selector('h1.success', :contents => assigns(:spell))
  end

  it "should render an effigy layout" do
    create_rails_source_file 'app/controllers/magic_controller.rb', <<-RUBY
      class MagicController < ApplicationController
        layout 'application'
      end
    RUBY

    create_rails_file 'app/views/magic/index.html.effigy', <<-RUBY
      class MagicIndexView < Effigy::Rails::View
      end
    RUBY

    create_rails_file 'app/templates/magic/index.html', <<-HTML
      <h1 class="success">title</h1>
    HTML

    create_rails_file 'app/views/layouts/application.html.effigy', <<-RUBY
      class ApplicationLayout < Effigy::Rails::View
        def transform
          html('body', content_for(:layout))
        end
      end
    RUBY

    create_rails_file 'app/templates/layouts/application.html', <<-HTML
      <html><body></body></html>
    HTML

    response = render(MagicController.new)

    response.should be_success
    response.body.should have_selector('html body h1.success')
  end

  it "should render an effigy partial" do
    create_rails_source_file 'app/controllers/magic_controller.rb', <<-RUBY
      class WandController < ApplicationController
      end
    RUBY

    create_rails_file 'app/views/wand/index.html.effigy', <<-RUBY
      class WandIndexView < Effigy::Rails::View
        def transform
          replace_with('p', partial('spell', :locals  => { :name => 'hocus pocus' }))
        end
      end
    RUBY

    create_rails_file 'app/templates/wand/index.html', <<-HTML
      <div>
        <h1 class="success">spell</h1>
        <p>placeholder</p>
      </div>
    HTML

    create_rails_file 'app/views/wand/_spell.html.effigy', <<-RUBY
      class WandSpellPartial < Effigy::Rails::View
        def transform
          text('p', @name)
        end
      end
    RUBY

    create_rails_file 'app/templates/wand/_spell.html', <<-HTML
      <p>put a spell on me</p>
    HTML

    response = render(WandController.new)

    response.should be_success
    response.body.should have_selector('div p', :contents => 'hocus pocus')
  end
end
