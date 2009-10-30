require 'nokogiri'
require 'effigy/class_list'
require 'effigy/errors'

module Effigy
  class View
    def text(selector, content)
      select(selector).content = content
    end

    def attributes(selector, attributes)
      element = select(selector)
      attributes.each do |attribute, value|
        element[attribute.to_s] = value
      end
    end

    def replace_with_each(selector, collection, &block)
      original_element = select(selector)
      collection.inject(original_element) do |sibling, item|
        item_element = clone_element_with_item(original_element, item, &block)
        sibling.add_next_sibling(item_element)
      end
      original_element.unlink
    end

    def render(template)
      @current_context = Nokogiri::XML.parse(template)
      yield if block_given?
      transform
      current_context.to_s
    end

    def context(new_context)
      old_context = @current_context
      @current_context = select(new_context)
      yield
      @current_context = old_context
    end

    def remove(selector)
      select_all(selector).each { |element| element.unlink }
    end

    def add_class_names(selector, *class_names)
      element = select(selector)
      class_list = ClassList.new(element)
      class_names.each { |class_name| class_list << class_name }
    end

    def remove_class_names(selector, *class_names)
      element = select(selector)
      class_list = ClassList.new(element)
      class_names.each { |class_name| class_list.remove(class_name) }
    end

    private

    def transform
    end

    attr_reader :current_context

    def select(nodes)
      if nodes.respond_to?(:search)
        nodes
      else
        current_context.at(nodes) or
          raise ElementNotFound, nodes
      end
    end

    def select_all(selector)
      result = current_context.search(selector)
      raise ElementNotFound, selector if result.empty?
      result
    end

    def clone_element_with_item(original_element, item, &block)
      item_element = original_element.dup
      context(item_element) { yield(item) }
      item_element
    end

  end
end
