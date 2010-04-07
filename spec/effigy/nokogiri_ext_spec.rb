require 'spec_helper'
require 'effigy/nokogiri_ext'

describe Nokogiri::XML::Node do
  it "should merge the given attributes" do
    html = %{<node one="abc" two="def" />}
    document = Nokogiri::HTML.parse(html)
    node = document.at("//node")

    node.merge!('two' => '2', :three => '3')

    result = document.to_html
    result.should have_selector('node[one="abc"]')
    result.should have_selector('node[two="2"]')
    result.should have_selector('node[three="3"]')
    result.should_not have_selector('node[two="def"]')
  end

  it "should append children from the given fragment" do
    html = %{<test>start</test>}
    document = Nokogiri::HTML.parse(html)
    node = document.at("//test")

    node.append_fragment '<p>middle</p><p>end</p>'

    result = document.to_html
    result.should include(%{<test>start})
    result.should have_selector('test p', :contents => 'middle')
    result.should have_selector('test p', :contents => 'end')
  end
end
