require 'spec_helper'

RAILS_ROOT = File.join(PROJECT_ROOT, 'tmp', 'rails_root')
require File.join(RAILS_ROOT, 'config', 'environment')
require File.join(PROJECT_ROOT, 'rails', 'init')
require 'action_view/test_case'
require 'nokogiri'

describe "a controller with an effigy view and template" do
  before do
    @files = []
    create_rails_source_file 'app/controllers/magic_controller.rb', <<-RUBY
      class MagicController < ApplicationController
        include ActionController::TestCase::RaiseActionExceptions
        def index
          @spell = 'hocus pocus'
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
      <html><h1>placeholder title</h1></html>
    HTML

    @controller = MagicController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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

  include ActionController::TestProcess

  it "should use the view to render the template" do
    get :index
    @response.should be_success
    @response.rendered[:template].to_s.should == 'magic/index.html.effigy'
    assigns(:spell).should_not be_nil
    @response.body.should have_selector('h1', :contents => assigns(:spell))
  end
end
