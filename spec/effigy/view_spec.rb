require 'spec_helper'
require 'effigy/view'

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

    it "should replace examples" do
      template = %{<test><element><value>original</value></element></test>}

      view = Effigy::View.new
      xml = view.render(template) do
        view.examples_for('element', %w(one two)) do |value|
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
  end
end