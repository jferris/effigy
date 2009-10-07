require 'nokogiri'

module Effigy
  class View
    def initialize
      @css_assignments   = {}
      @xpath_assignments = {}
    end

    def text(selector, content)
      contenxt.search(selector).each do |element|
        element.content = content
      end
    end

    def attributes(selector, attributes)
      contenxt.search(selector).each do |element|
        attributes.each do |attribute, value|
          element[attribute.to_s] = value
        end
      end
    end

    def render(template)
      @contenxt = Nokogiri::XML.parse(template)
      yield
      contenxt.to_s
    end

    private

    attr_reader :contenxt

  end
end
