require 'spec_helper'
require 'effigy/class_list'

describe Effigy::ClassList do

  it "should add a class name to an element with one existing class name" do
    element = Nokogiri::XML.parse(%{<test class="original"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list << 'another'
    element.should have_selector('test.original')
    element.should have_selector('test.another')
  end

  it "should add a class name to an element with two existing class names" do
    element = Nokogiri::XML.parse(%{<test class="one two"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list << 'another'
    element.should have_selector('test.one')
    element.should have_selector('test.two')
    element.should have_selector('test.another')
  end

  it "should add a class name to an element without a class attribute" do
    element = Nokogiri::XML.parse(%{<test/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list << 'another'
    element.should have_selector('test.another')
  end

  it "should remove a class name from an element with one existing class name" do
    element = Nokogiri::XML.parse(%{<test class="original"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list.remove 'original'
    element.should_not have_selector('test.original')
  end

  it "should remove a class name from an element with two existing class names" do
    element = Nokogiri::XML.parse(%{<test class="one two"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list.remove 'one'
    element.should have_selector('test.two')
    element.should_not have_selector('test.one')
  end

end
