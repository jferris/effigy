module Effigy
  # Performs transformations based on an array of example elements. Used internally.
  # @see Effigy::View#replace_each
  class ExampleElementTransformer
    def initialize(view, example_elements)
      @view = view
      @example_elements = example_elements
    end

    # Replaces the example elements with a clone for each item in the
    # collection. Only the first example element will be used for cloning,  but
    # all example elements will be removed.
    #
    # @param [Enumerable] collection the items that are the base for each
    #   cloned element
    def replace_each(collection, &block)
      clone_and_transform_each(collection, &block)
      remove_all
    end

    private

    # [Effigy::View] the source view on which transformations should be performed
    attr_reader :view

    # [Array] the list of example elements to transform and clone
    attr_reader :example_elements

    # Creates a clone for each item in the collection and yields it for
    # transformation along with the corresponding item. The transformed clones
    # are inserted after the element to clone.
    # @param [Array] collection data that cloned elements should be transformed with
    # @yield [Nokogiri::XML::Node] the cloned element
    # @yield [Object] an item from the collection
    def clone_and_transform_each(collection, &block)
      collection.inject(element_to_clone) do |sibling, item|
        item_element = clone_with_item(item, &block)
        sibling.add_next_sibling(item_element)
      end
    end

    # Removes all example elements
    def remove_all
      example_elements.each { |element| element.unlink }
    end

    # The first example element, which will be used when creating a clone for transformations
    def element_to_clone
      example_elements.first
    end

    # Creates a clone and yields it to the given block along with the given item.
    # @param [Object] item the item to use with the clone
    # @yield [Nokogiri::XML:Node] the cloned node
    # @yield [Object] the given item
    # @return [Nokogiri::XML::Node] the transformed clone
    def clone_with_item(item, &block)
      item_element = element_to_clone.dup
      view.find(item_element) { yield(item) }
      item_element
    end
  end
end
