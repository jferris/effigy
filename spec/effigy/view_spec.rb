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
  end
end
