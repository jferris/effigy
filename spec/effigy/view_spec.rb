require 'spec_helper'
require 'effigy/view'

module Effigy
  describe View do
    it "should replace element contents with css values" do
      template = <<-XML
      <?xml version="1.0"?>
      <test><element>something</element></test>
      XML

      view = Effigy::View.new
      view.css 'element', 'expected'
      xml = view.render(template)

      document = Nokogiri::XML.parse(xml)
      document.at('//element').text.should == 'expected'
    end
  end
end
