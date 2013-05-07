require 'spec_helper'
require 'effigy/example_element_transformer'
require 'effigy/view'

describe Effigy::ExampleElementTransformer do
  it "should replace all selected elements with a clone for each item in a collection" do
    view = Effigy::View.new
    class << view
      def transform
        elements = select('element')
        transformer = Effigy::ExampleElementTransformer.new(self, elements)
        transformer.replace_each(%w(one two)) do |value|
          find('value').text(value)
        end
      end
    end

    template = %{<test>
                   <element><value>original</value></element>
                   <element><value>dup</value></element>
                 </test>}
    xml = view.render_html_fragment(template)

    xml.should have_selector('element value', :contents => 'one')
    xml.should have_selector('element value', :contents => 'two')
    xml.should_not have_selector('element value', :contents => 'original')
    xml.should_not have_selector('element value', :contents => 'dup')
    xml.should =~ /one.*two/m
  end
end
