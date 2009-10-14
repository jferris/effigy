require 'spec_helper'
require 'effigy/view'
require 'effigy/errors'

module Effigy
  describe View do
    it "should replace element contents" do
      template = %{<test><element one="abc">something</element></test>}

      view = Effigy::View.new
      xml = view.render(template) do
        view.text 'element', 'expected'
      end

      xml.should have_selector(:element, :contents => 'expected', :one => 'abc')
    end

    it "should replace element attributes" do
      template = %{<test><element one="abc">something</element></test>}

      view = Effigy::View.new
      xml = view.render(template) do
        view.attributes 'element', :one => '123', :two => '234'
      end

      xml.should have_selector(:element, :contents => 'something', :one => '123', :two => '234')
    end

    it "should replace an element with a clone for each item in a collection" do
      template = %{<test><element><value>original</value></element></test>}

      view = Effigy::View.new
      xml = view.render(template) do
        view.replace_with_each('element', %w(one two)) do |value|
          view.text('value', value)
        end
      end

      xml.should have_selector('element value', :contents => 'one')
      xml.should have_selector('element value', :contents => 'two')
      xml.should_not have_selector('element value', :contents => 'original')
      xml.should =~ /one.*two/m
    end

    it "should replace within a context" do
      template = %{<test><element><value>original</value></element></test>}

      view = Effigy::View.new
      xml = view.render(template) do
        view.context('element') do
          view.text('value', 'expected')
        end
      end

      xml.should have_selector('element value', :contents => 'expected')
    end

    it "should remove all matching elements" do
      template = %{<test><first class="yes"/><other class="yes"/><last class="no"/></test>}

      view = Effigy::View.new
      xml = view.render(template) do
        view.remove('.yes')
      end

      xml.should have_selector('.no')
      xml.should_not have_selector('.yes')
    end

    it "should add the given class names" do
      template = %{<test class="original"/>}

      view = Effigy::View.new
      xml = view.render(template) do
        view.add_class_names('test', 'one', 'two')
      end

      xml.should have_selector('test.original')
      xml.should have_selector('test.one')
      xml.should have_selector('test.two')
    end

    it "should remove the given class names" do
      template = %{<test class="one two three"/>}

      view = Effigy::View.new
      xml = view.render(template) do
        view.remove_class_names('test', 'one', 'two')
      end

      xml.should have_selector('test.three')
      xml.should_not have_selector('test.one')
      xml.should_not have_selector('test.two')
    end

    describe "given a template without .find" do
      def render(&block)
        lambda do
          view = Effigy::View.new
          view.render('<test/>') { block.call(view) }
        end
      end

      it "should raise when updating text content for .find" do
        render { |view| view.text('.find', 'value') }.should raise_error(Effigy::ElementNotFound)
      end

      it "should raise when updating attributes for .find" do
        render { |view| view.attributes('.find', :attr => 'value') }.
          should raise_error(Effigy::ElementNotFound)
      end

      it "should raise when replacing an element matching .find" do
        render { |view| view.replace_with_each('.find', []) }.
          should raise_error(Effigy::ElementNotFound)
      end

      it "should raise when removing elements matching .find" do
        render { |view| view.remove('.find') }.
          should raise_error(Effigy::ElementNotFound)
      end

      it "should raise when setting the context to .find" do
        render { |view| view.context('.find') }.
          should raise_error(Effigy::ElementNotFound)
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
          text('element', @value)
        end
      end
    end

    it "should run #transform when rendering" do
      template = %{<test><element>original</element></test>}
      view = @subclass.new('expected')
      view.render(template).should have_selector('element', :contents => 'expected')
    end
  end
end
