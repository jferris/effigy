require 'spec_helper'
require 'effigy/view'

module Effigy
  describe View do
    it "should replace element text" do
      template = %{<test>
                     <element one="abc">something</element>
                     <element two="abc">else</element>
                   </test>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('element').text('expected')
      end

      html.should have_selector(:element, :contents => 'expected', :one => 'abc')
      html.should have_selector(:element, :contents => 'expected', :two => 'abc')
    end

    it "should replace element attributes" do
      template = %{<test>
        <element one="abc">something</element>
        <element two="abc">else</element>
        </test>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('element').attr(:one => '123', :two => '234')
      end

      html.should have_selector(:element, :contents => 'something', :one => '123', :two => '234')
      html.should have_selector(:element, :contents => 'else', :one => '123', :two => '234')
    end

    it "should replace one attribute" do
      template = %{<test><element one="abc">something</element></test>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('element').attr(:one, '123')
      end

      html.should have_selector(:element, :contents => 'something', :one => '123')
    end

    it "should replace all selected elements with a clone for each item in a collection" do
      template = %{<test>
                     <element><value>original</value></element>
                     <element><value>dup</value></element>
                   </test>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('element').tap do |v|
          v.replace_each(%w(one two)) do |value|
            v.find('value').text(value)
          end
        end
      end

      html.should have_selector('element value', :contents => 'one')
      html.should have_selector('element value', :contents => 'two')
      html.should_not have_selector('element value', :contents => 'original')
      html.should_not have_selector('element value', :contents => 'dup')
      html.should =~ /one.*two/m
    end

    it "should replace within a context" do
      template = %{<test><element><value>original</value></element></test>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('element') do
          view.find('value').text('expected')
        end
      end

      html.should have_selector('element value', :contents => 'expected')
    end

    it "should remove all matching elements" do
      template = %{<test><first class="yes"/><other class="yes"/><last class="no"/></test>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('.yes').remove
      end

      html.should have_selector('.no')
      html.should_not have_selector('.yes')
    end

    it "should add the given class names" do
      template = %{<test class="original"/>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('test').add_class('one', 'two')
      end

      html.should have_selector('test.original')
      html.should have_selector('test.one')
      html.should have_selector('test.two')
    end

    it "should remove the given class names" do
      template = %{<test class="one two three"/>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('test').remove_class('one', 'two')
      end

      html.should have_selector('test.three')
      html.should_not have_selector('test.one')
      html.should_not have_selector('test.two')
    end

    it "should replace an element's inner markup" do
      template = %{<test><original>contents</original></test>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('test').html('<b>replaced</b>')
      end

      html.should have_selector('test b', :contents => 'replaced')
      html.should_not have_selector('original')
    end

    it "should replace an element's outer markup" do
      template = %{<test><original>contents</original></test>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('test').replace_with('<b>replaced</b>')
      end

      html.should have_selector('b', :contents => 'replaced')
      html.should_not have_selector('test')
    end

    it "should append text to elements" do
      template = %{<outer><test class="abc">start</test><other class="abc">start</other></outer>}

      view = Effigy::View.new
      html = view.render_html_fragment(template) do
        view.find('.abc').append('<p>middle</p><p>end</p>')
      end

      html.should include(%{<test class="abc">start})
      html.should have_selector('test p', :contents => 'middle')
      html.should have_selector('test p', :contents => 'end')
      html.should include(%{<other class="abc">start})
      html.should have_selector('other p', :contents => 'middle')
      html.should have_selector('other p', :contents => 'end')
    end

    it "should render an html document" do
      template = %{<html/>}
      html = Effigy::View.new.render_html_document(template)
      html.should_not include('<?xml')
      html.should_not include('xmlns')
      html.should have_selector('html')
    end

    it "should keep multiple top-level elements" do
      template = %{<p>fragment one</p><p>fragment two</p>}
      html = Effigy::View.new.render_html_fragment(template)
      html.should include('one')
      html.should include('two')
    end

    it "should handle html fragments" do
      template = %{<h1>hello</h1>}
      html = Effigy::View.new.render_html_fragment(template)
      html.should == template
    end

    %w(find f).each do |chain_method|
      it "should allow chains using #{chain_method}" do
        template = %{<test><element one="abc">something</element></test>}

        view = Effigy::View.new
        html = view.render_html_fragment(template) do
          view.send(chain_method, 'element').text('expected')
        end

        html.should have_selector(:element, :contents => 'expected', :one => 'abc')
      end
    end

    describe "given a template without .find" do
      def render(&block)
        lambda do
          view = Effigy::View.new
          view.render_html_fragment('<test/>') { block.call(view) }
        end
      end

      it "should not raise when updating text content for .find" do
        render { |view| view.find('.find').text('value') }.should_not raise_error
      end

      it "should not raise when updating attributes for .find" do
        render { |view| view.find('.find').attr(:attr => 'value') }.should_not raise_error
      end

      it "should not raise when replacing an element matching .find" do
        render { |view| view.find('.find').replace_each([]) }.should_not raise_error
      end

      it "should not raise when removing elements matching .find" do
        render { |view| view.find('.find').remove }.should_not raise_error
      end

      it "should not raise when setting the context to .find" do
        render { |view| view.find('.find') {} }.should_not raise_error
      end
    end
  end

  describe View, "subclass" do
    before do
      @subclass = Class.new(View)
      @subclass.class_eval do
        def initialize(value)
          @value = value
        end

        def transform
          find('element').text(@value)
        end
      end
    end

    it "should run #transform when rendering" do
      template = %{<test><element>original</element></test>}
      view = @subclass.new('expected')
      view.render_html_fragment(template).should have_selector('element', :contents => 'expected')
    end
  end
end
