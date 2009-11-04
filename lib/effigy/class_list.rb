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

    # Appends a class name to the list.
    # @param [String] class_name the class name to append
    def <<(class_name)
      @class_names << class_name
      write_class_names
    end

    # Removes a class name from the list.
    # @param [String] class_name the class name to remove
    def remove(class_name)
      @class_names.delete(class_name)
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
