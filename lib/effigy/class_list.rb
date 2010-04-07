require 'nokogiri'

module Effigy
  # Internal use only.
  #
  # Used when parsing and manipulating lists of CSS class names.
  class ClassList
    # @param element [Nokogiri::XML::Element] the element whose class names
    #   should be manipulated
    def initialize(element)
      @element = element
      read_class_names
    end

    # Appends the given class names to the list.
    # @param [Array] class_names the class name to append
    def add(class_names)
      @class_names += class_names
      write_class_names
    end

    # Removes the given class names from the list.
    # @param [Array] class_names the class names to remove
    def remove(class_names)
      @class_names -= class_names
      write_class_names
    end

    private

    # Parses and caches the list of class names. Called after initialization.
    def read_class_names
      @class_names = (@element['class'] || '').split(' ')
    end

    # Writes the transformed list of classes to the element's class attribute.
    def write_class_names
      @element['class'] = @class_names.join(' ')
    end
  end
end
