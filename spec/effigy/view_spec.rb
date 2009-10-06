require 'spec_helper'
require 'effigy/view'

module Effigy
  describe View do
    it "should replace element contents and attributes using a css selector" do
      template = %{<test><element one="abc">something</element></test>}

      view = Effigy::View.new
      view.css 'element', :contents => 'expected', :one => '123', :two => '234'
      xml = view.render(template)

      xml.should have_selector(:element, :contents => 'expected', :one => '123', :two => '234')
    end

    it "should replace just element contents using a css selector" do
      template = %{<test><element one="abc">something</element></test>}

      view = Effigy::View.new
      view.css 'element', :contents => 'expected'
      xml = view.render(template)

      xml.should have_selector(:element, :contents => 'expected', :one => 'abc')
    end

    it "should replace just element attributes using a css selector" do
      template = %{<test><element one="abc">something</element></test>}

      view = Effigy::View.new
      view.css 'element', :one => 'expected'
      xml = view.render(template)

      xml.should have_selector(:element, :contents => 'something', :one => 'expected')
    end

    it "should replace element contents and attributes using xpath" do
      template = %{<test><element one="abc">something</element></test>}

      view = Effigy::View.new
      view.xpath '//element[@one="abc"]', :contents => 'expected', :one => '123', :two => '234'
      xml = view.render(template)

      xml.should have_selector(:element, :contents => 'expected', :one => '123', :two => '234')
    end

    it "should replace just element contents using xpath" do
      template = %{<test><element one="abc">something</element></test>}

      view = Effigy::View.new
      view.xpath '//element[@one="abc"]', :contents => 'expected'
      xml = view.render(template)

      xml.should have_selector(:element, :contents => 'expected', :one => 'abc')
    end

    it "should replace just element attributes using xpath" do
      template = %{<test><element one="abc">something</element></test>}

      view = Effigy::View.new
      view.xpath '//element[@one="abc"]', :one => 'expected'
      xml = view.render(template)

      xml.should have_selector(:element, :contents => 'something', :one => 'expected')
    end
  end
end
