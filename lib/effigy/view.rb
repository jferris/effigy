require 'nokogiri'
require 'effigy/class_list'
require 'effigy/core_ext/hash'
require 'effigy/core_ext/object'
require 'effigy/nokogiri_ext'
require 'effigy/example_element_transformer'

module Effigy
  # Accepts a template to be transformed.
  #
  # For most common cases, creating a subclass makes the most sense, but this
  # class can be used directly by passing a block to {#render_html_document} or
  # {#render_html_fragment}.
  #
  # @see #transform
  # @see #render_html_document
  # @see #render_html_fragment
  # @example
  # view = Effigy::View.new
  # view.render_html_document(template) do
  #   view.find('h1').text('the title')
  # end
  #
  class View
    # Replaces the text content of the selected elements.
    #
    # Markup in the given content is escaped. Use {#html} if you want to
    # replace the contents with live markup.
    #
    # @param [String] selector a CSS or XPath string describing the elements to
    #   transform
    # @param [String] content the text that should be the new contents
    # @example
    #   text('h1', 'a title')
    #   find('h1').text('a title')
    #   text('p', '<b>title</b>') # <p>&lt;b&gt;title&lt;/title&gt;</p>
    def text(content)
      current_context.each do |node|
        node.content = content
      end
    end

    # Adds or updates the given attribute or attributes of the selected elements.
    #
    # @param [String] selector a CSS or XPath string describing the elements to
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
    def attr(attributes_or_attribute_name, value = nil)
      attributes = attributes_or_attribute_name.to_effigy_attributes(value)
      current_context.each do |element|
        element.merge!(attributes)
      end
    end

    # Replaces the selected elements with a clone for each item in the
    # collection. If multiple elements are selected, only the first element
    # will be used for cloning. All selected elements will be removed.
    #
    # @param [String] selector a CSS or XPath string describing the elements to
    #   transform
    # @param [Enumerable] collection the items that are the base for each
    #   cloned element
    # @example
    #   titles = %w(one two three)
    #   find('.post').replace_each(titles) do |title|
    #     text('h1', title)
    #   end
    def replace_each(collection, &block)
      ExampleElementTransformer.new(self, current_context).replace_each(collection, &block)
    end

    # Perform transformations on a string containing an html fragment.
    #
    # @yield inside the given block, transformation methods such as #text and
    #   #html can be used on the template. Using a subclass, you can instead
    #   override the #transform method, which is the preferred approach.
    #
    # @return [String] the transformed fragment
    def render_html_fragment(template, &block)
      yield_transform_and_output(Nokogiri::HTML.fragment(template), &block)
    end

    # Perform transformations on a string containing an html document.
    #
    # @yield inside the given block, transformation methods such as #text and
    #   #html can be used on the template. Using a subclass, you can instead
    #   override the #transform method, which is the preferred approach.
    #
    # @return [String] the transformed document
    def render_html_document(template, &block)
      yield_transform_and_output(Nokogiri::HTML.parse(template), &block)
    end

    # Removes the selected elements from the template.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @example
    #   remove('.post')
    #   find('.post').remove
    def remove
      current_context.each { |element| element.unlink }
    end

    # Adds the given class names to the selected elements.
    #
    # @param [String] selector a CSS or XPath string describing the elements to
    #   transform
    # @param [String] class_names a CSS class name that should be added
    # @example
    #   add_class('a#home', 'selected')
    #   find('a#home').add_class('selected')
    def add_class(*class_names)
      current_context.each do |element|
        class_list = ClassList.new(element)
        class_list.add class_names
      end
    end

    # Removes the given class names from the selected elements.
    #
    # Ignores class names that are not present.
    #
    # @param [String] selector a CSS or XPath string describing the elements to
    #   transform
    # @param [String] class_names a CSS class name that should be removed
    # @example
    #   remove_class('a#home', 'selected')
    #   find('a#home').remove_class('selected')
    def remove_class(*class_names)
      current_context.each do |element|
        class_list = ClassList.new(element)
        class_list.remove(class_names)
      end
    end

    # Replaces the contents of the selected elements with live markup.
    #
    # @param [String] selector a CSS or XPath string describing the elements to
    #   transform
    # @param [String] inner_html the new contents of the selected elements. Markup is
    # @example
    #   html('p', '<b>Welcome!</b>')
    #   find('p').html('<b>Welcome!</b>')
    def html(inner_html)
      current_context.each do |node|
        node.inner_html = inner_html
      end
    end

    # Replaces the selected element with live markup.
    #
    # The "outer HTML" for the selected tag itself is also replaced.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @param [String] html the new markup to replace the selected element. Markup is
    #   not escaped.
    def replace_with(html)
      current_context.after(html).unlink
    end

    # Adds the given markup to the end of the selected elements.
    #
    # @param [String] selector a CSS or XPath string describing the elements to
    #   which this HTML should be appended
    # @param [String] html_to_append the new markup to append to the selected
    #   element. Markup is not escaped.
    def append(html_to_append)
      current_context.each { |node| node.append_fragment html_to_append }
    end

    # Selects an element or elements for chained transformation.
    #
    # If given a block, the selection will be in effect during the block.
    #
    # @param [String] selector a CSS or XPath string describing the element to
    #   transform
    # @return [self]
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
        dup.with_selector(selector)
      end
    end
    alias_method :f, :find

    # Called by render methods to perform transformations on the source
    # template. Override this method in subclasses to perform the
    # transformations specific to your view.
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

    protected

    def with_selector(selector)
      self.current_context = select(selector)
      self
    end

    private

    # The current set of nodes on which transformations are performed.
    #
    # This is usually the entire document, but will be a subset of child nodes
    # during {#find} blocks.
    attr_accessor :current_context

    # Returns a set of nodes matching the given selector, or the nodes
    # themselves if given a set of nodes.
    #
    # @param nodes [String,Nokogiri::HTML::NodeSet] if a String, the selector to
    #   use when determining the current context. When a NodeSet, the set of
    #   nodes that should be returned.
    # @return [Nokogiri::HTML::NodeSet] the nodes selected by the given selector
    #   or node set.
    def select(nodes)
      if nodes.respond_to?(:search)
        nodes
      else
        current_context.search(nodes)
      end
    end

    # Clones an element, sets it as the current context, and yields to the
    # given block with the given item.
    #
    # @param [Nokogiri::HTML::Element] the element to clone
    # @param [Object] item the item that should be yielded to the block
    # @yield [Object] the item passed as item
    # @return [Nokogiri::HTML::Element] the clone of the original element
    def clone_element_with_item(original_element, item, &block)
      item_element = original_element.dup
      find(item_element) { yield(item) }
      item_element
    end

    # Converts the transformed document to a string.
    #
    # Called by render methods after transforming the document using a passed
    # block and {#transform}.
    #
    # Override this in subclasses if you wish to return something besides an
    # XHTML string representation of the transformed document.
    #
    # @return [String] the transformed document as a string
    def output
      current_context.to_html
    end

    # Uses the given document or fragment as a basis for transformation.
    #
    # @yield self, with the document or fragment set as the context.
    #
    # @return [String] the transformed document or fragment as a string
    def yield_transform_and_output(document_or_fragment)
      @current_context = document_or_fragment
      yield if block_given?
      transform
      output
    end
  end
end
