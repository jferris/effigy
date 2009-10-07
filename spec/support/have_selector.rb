module Matchers
  class HaveSelector
    def initialize(selector, attrs)
      @selector = selector
      @attrs    = attrs
      @contents = attrs.delete(:contents)
    end

    def matches?(xml)
      @xml     = xml

      verify_element_present! &&
        verify_contents! &&
        verify_attrs!
    end

    def failure_message
      "Expected #{@missing},\nGot: #{elements.to_a.join("\n")}"
    end

    def negative_failure_message
      "Did not expect #{@missing}"
    end

    private

    attr_reader :xml, :selector, :attrs, :contents, :missing

    def verify_element_present!
      if elements.empty?
        @missing = "an element matching the following CSS selector: #{selector}"
        false
      else
        true
      end
    end

    def verify_contents!
      if contents.nil? || elements.any? { |element| element.text == @contents}
        true
      else
        @missing = "element with contents: #{@contents}"
        false
      end
    end

    def verify_attrs!
      if elements.any? { |element| attrs.all? { |attribute, value| element[attribute.to_s] == value } }
        true
      else
        @missing = "element with attrs: #{attrs.inspect}"
        false
      end
    end

    def elements
      @elements ||= document.css(selector.to_s)
    end

    def document
      @document ||= Nokogiri::XML.parse(xml)
    end
  end

  def have_selector(selector, attrs = {})
    HaveSelector.new(selector, attrs)
  end
end
