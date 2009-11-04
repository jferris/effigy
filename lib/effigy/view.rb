require 'nokogiri'
require 'effigy/class_list'
require 'effigy/errors'
require 'effigy/selection'

module Effigy
  # Accepts a template to be transformed.
  #
  # For most common cases, creating a subclass makes the most sense, but this
  # class can be used directly by passing a block to {#render}.
  #
  # @see #transform
  # @see #render
  # @example
  # view = Effigy::View.new
  # view.render(template) do
  #   view.find('h1').text('the title')
  # end
  #
  class View
    # Replaces the text content of the selected element.
    #
    # Markup in the given content is escaped. Use {#html} if you want to
    # replace the contents with live markup.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @param [String] content the text that should be the new element contents
    # @example
    #   text('h1', 'a title')
    #   find('h1').text('a title')
    #   text('p', '<b>title</b>') # <p>&lt;b&gt;title&lt;/title&gt;</p>
    def text(selector, content)
      select(selector).content = content
    end

    # Adds or updates the given attribute or attributes of the selected element.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @param [String,Hash] attributes_or_attribute_name if a String, replaces
    #   that attribute with the given value. If a Hash, uses the keys as
    #   attribute names and values as attribute values
    # @param [String] value the value for the replaced attribute. Used only if
    #   attributes_or_attribute_name is a String
    # @example
    #   attr('p', :id => 'an_id', :style => 'display: none')
    #   attr('p', :id, 'an_id')
    #   find('p').attr(:id, 'an_id')
    def attr(selector, attributes_or_attribute_name, value = nil)
      element = select(selector)
      attributes = attributes_or_attribute_name.to_effigy_attributes(value)
      attributes.each do |attribute, value|
        element[attribute.to_s] = value
      end
    end

    # Replaces the selected element with a clone for each item in the collection.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @param [Enumerable] collection the items that are the base for each
    #   cloned element
    # @example
    #   titles = %w(one two three)
    #   find('.post').replace_each(titles) do |title|
    #     text('h1', title)
    #   end
    def replace_each(selector, collection, &block)
      original_element = select(selector)
      collection.inject(original_element) do |sibling, item|
        item_element = clone_element_with_item(original_element, item, &block)
        sibling.add_next_sibling(item_element)
      end
      original_element.unlink
    end

    # Perform transformations on the given template.
    #
    # @yield inside the given block, transformation methods such as #text and
    #   #html can be used on the template. Using a subclass, you can instead
    #   override the #transform method, which is the preferred approach.
    #
    # @return [String] the resulting document
    def render(template)
      @current_context = Nokogiri::XML.parse(template)
      yield if block_given?
      transform
      output
    end

    # Removes the selected elements from the template.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @example
    #   remove('.post') # removes all elements with a class of "post"
    #   find('.post').remove
    def remove(selector)
      select_all(selector).each { |element| element.unlink }
    end

    def add_class(selector, *class_names)
      element = select(selector)
      class_list = ClassList.new(element)
      class_names.each { |class_name| class_list << class_name }
    end

    def remove_class(selector, *class_names)
      element = select(selector)
      class_list = ClassList.new(element)
      class_names.each { |class_name| class_list.remove(class_name) }
    end

    def html(selector, xml)
      select(selector).inner_html = xml
    end

    def replace_with(selector, xml)
      select(selector).after(xml).unlink
    end

    def find(selector)
      if block_given?
        old_context = @current_context
        @current_context = select(selector)
        yield
        @current_context = old_context
      else
        Selection.new(self, selector)
      end
    end
    alias_method :f, :find

    def transform
    end

    private

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
      find(item_element) { yield(item) }
      item_element
    end

    def output
      current_context.to_xhtml
    end

  end
end
