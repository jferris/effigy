require 'nokogiri'

module Effigy
  class View
    def initialize
      @css_assignments   = {}
      @xpath_assignments = {}
    end

    def css(selector, assignments)
      @css_assignments[selector] = assignments
    end

    def xpath(selector, assignments)
      @xpath_assignments[selector] = assignments
    end

    def render(template)
      document = Nokogiri::XML.parse(template)
      @css_assignments.each do |selector, assignments|
        use_assignments(document.css(selector), assignments)
      end
      @xpath_assignments.each do |selector, assignments|
        use_assignments(document.xpath(selector), assignments)
      end
      document.to_s
    end

    private

    def use_assignments(elements, assignments)
      contents = assignments.delete(:contents)
      elements.each do |element|
        element.content = contents if contents
        assignments.each do |attribute, value|
          element[attribute.to_s] = value
        end
      end
    end
  end
end
