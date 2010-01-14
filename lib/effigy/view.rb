require 'nokogiri'
require 'effigy/class_list'
require 'effigy/errors'
require 'effigy/selection'
require 'effigy/core_ext/hash'
require 'effigy/core_ext/object'

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
    #   remove('.post')
    #   find('.post').remove
    def remove(selector)
      select_all(selector).each { |element| element.unlink }
    end

    # Adds the given class names to the selected element.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @param [String] class_names a CSS class name that should be added
    # @example
    #   add_class('a#home', 'selected')
    #   find('a#home').add_class('selected')
    def add_class(selector, *class_names)
      element = select(selector)
      class_list = ClassList.new(element)
      class_names.each { |class_name| class_list << class_name }
    end

    # Removes the given class names from the selected element.
    #
    # Ignores class names that are not present.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @param [String] class_names a CSS class name that should be removed
    # @example
    #   remove_class('a#home', 'selected')
    #   find('a#home').remove_class('selected')
    def remove_class(selector, *class_names)
      element = select(selector)
      class_list = ClassList.new(element)
      class_names.each { |class_name| class_list.remove(class_name) }
    end

    # Replaces the contents of the selected element with live markup.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @param [String] xml the new contents of the selected element. Markup is
    #   not escaped.
    # @example
    #   html('p', '<b>Welcome!</b>')
    #   find('p').html('<b>Welcome!</b>')
    def html(selector, xml)
      select(selector).inner_html = xml
    end

    # Replaces the selected element with live markup.
    #
    # The "outer HTML" for the selected tag itself is also replaced.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @param [String] xml the new markup to replace the selected element. Markup is
    #   not escaped.
    def replace_with(selector, xml)
      select(selector).after(xml).unlink
    end

    # Selects an element or elements for chained transformation.
    #
    # If given a block, the selection will be in effect during the block.
    #
    # If not given a block, a {Selection} will be returned on which
    # transformation methods can be called. Any methods called on the
    # Selection will be delegated back to the view with the selector inserted
    # into the parameter list.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @return [Selection] a proxy object on which transformation methods can be
    #   called
    # @example
    #   find('.post') do
    #     text('h1', post.title)
    #     text('p', post.body)
    #   end
    #   find('h1').text(post.title).add_class('active')
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

    # Called by {#render} to perform transformations on the source template.
    #
    # Override this method in subclasses to perform the transformations
    # specific to your view.
    #
    # @example
    #   class PostView < Effigy::View
    #     def initialize(post)
    #       @post = post
    #     end
    #
    #     def transform
    #       find('.post') do
    #         find('h2').text(post.title)
    #         find('p').text(post.body)
    #       end
    #     end
    #   end
    def transform
    end

    private

    # The current set of nodes on which transformations are performed.
    #
    # This is usually the entire document, but will be a subset of child nodes
    # during {#find} blocks.
    attr_reader :current_context

    # Returns the first node that matches the given selection, or the nodes
    # themselves if given a set of nodes.
    #
    # @param nodes [String,Nokogiri::XML::NodeSet] if a String, the selector to
    #   use when determining the current context. When a NodeSet, the set of
    #   nodes that should be returned.
    # @return [Nokogiri::XML::NodeSet] the nodes selected by the given selector
    #   or node set.
    # @raise [ElementNotFound] if no nodes match the given selector
    def select(nodes)
      if nodes.respond_to?(:search)
        nodes
      else
        current_context.at(nodes) or
          raise ElementNotFound, nodes
      end
    end

    # Returns a set of nodes matching the given selector.
    #
    # @param selector [String] the selctor to use when finding nodes
    # @return [Nokogiri::XML::NodeSet] the nodes selected by the given selector
    # @raise [ElementNotFound] if no nodes match the given selector
    def select_all(selector)
      result = current_context.search(selector)
      raise ElementNotFound, selector if result.empty?
      result
    end

    # Clones an element, sets it as the current context, and yields to the
    # given block with the given item.
    #
    # @param [Nokogiri::XML::Element] the element to clone
    # @param [Object] item the item that should be yielded to the block
    # @yield [Object] the item passed as item
    # @return [Nokogiri::XML::Element] the clone of the original element
    def clone_element_with_item(original_element, item, &block)
      item_element = original_element.dup
      find(item_element) { yield(item) }
      item_element
    end

    # Converts the transformed document to a string.
    #
    # Called by {#render} after transforming the document using a passed block
    # and {#transform}.
    #
    # Override this in subclasses if you wish to return something besides an
    # XHTML string representation of the transformed document.
    #
    # @return [String] the transformed document as a string
    def output
      current_context.to_xhtml
    end

  end
end
