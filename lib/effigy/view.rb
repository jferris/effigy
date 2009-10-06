require 'nokogiri'

module Effigy
  class View
    def initialize
      @css_assignments = {}
    end

    def css(selector, value)
      @css_assignments[selector] = value
    end

    def render(template)
      document = Nokogiri::XML.parse(template)
      @css_assignments.each do |selector, value|
        document.css(selector).each do |element|
          element.content = value
        end
      end
      document.to_s
    end
  end
end
