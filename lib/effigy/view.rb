require 'nokogiri'

module Effigy
  class View
    def initialize
      @css_assignments   = {}
      @xpath_assignments = {}
    end

    def text(selector, content)
      select(selector).content = content
    end

    def attributes(selector, attributes)
      element = select(selector)
      attributes.each do |attribute, value|
        element[attribute.to_s] = value
      end
    end

    def examples_for(selector, collection, &block)
      original_element = current_context.at(selector)
      sibling = original_element
      collection.each do |item|
        item_element = original_element.dup
        context(item_element) { yield(item) }
        sibling.add_next_sibling(item_element)
        sibling = item_element
      end
      original_element.unlink
    end

    def render(template)
      @current_context = Nokogiri::XML.parse(template)
      yield
      current_context.to_s
    end

    def context(new_context)
      old_context = @current_context
      @current_context = select(new_context)
      yield
      @current_context = old_context
    end

    private

    attr_reader :current_context

    def select(nodes)
      if nodes.respond_to?(:search)
        nodes
      else
        current_context.at(nodes)
      end
    end

  end
end