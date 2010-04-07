require 'spec_helper'
require 'effigy/class_list'

describe Effigy::ClassList do

  it "should add a class name to an element with one existing class name" do
    element = Nokogiri::XML.parse(%{<test class="original"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list.add %w(another)
    element.should have_selector('test.original')
    element.should have_selector('test.another')
  end

  it "should add a class name to an element with two existing class names" do
    element = Nokogiri::XML.parse(%{<test class="one two"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list.add %w(another)
    element.should have_selector('test.one')
    element.should have_selector('test.two')
    element.should have_selector('test.another')
  end

  it "should add a class name to an element without a class attribute" do
    element = Nokogiri::XML.parse(%{<test/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list.add %w(another)
    element.should have_selector('test.another')
  end

  it "should remove a class name from an element with one existing class name" do
    element = Nokogiri::XML.parse(%{<test class="original"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list.remove %w(original)
    element.should_not have_selector('test.original')
  end

  it "should remove a class name from an element with two existing class names" do
    element = Nokogiri::XML.parse(%{<test class="one two"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list.remove %w(one)
    element.should have_selector('test.two')
    element.should_not have_selector('test.one')
  end

  it "should add several class names to an element" do
    element = Nokogiri::XML.parse(%{<test class="original"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list.add %w(one two)
    element.should have_selector('test.original')
    element.should have_selector('test.one')
    element.should have_selector('test.two')
  end

  it "should remove several class names from an element" do
    element = Nokogiri::XML.parse(%{<test class="one two three"/>}).at("//test")
    class_list = Effigy::ClassList.new(element)
    class_list.remove %w(one two)
    element.should_not have_selector('test.one')
    element.should_not have_selector('test.two')
    element.should have_selector('test.three')
  end

end
