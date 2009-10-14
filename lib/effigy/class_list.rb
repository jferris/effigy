require 'nokogiri'

module Effigy
  class ClassList
    def initialize(element)
      @element = element
      read_class_names
    end

    def <<(class_name)
      @class_names << class_name
      write_class_names
    end

    def remove(class_name)
      @class_names.delete(class_name)
      write_class_names
    end

    private

    def read_class_names
      @class_names = (@element['class'] || '').split(' ')
    end

    def write_class_names
      @element['class'] = @class_names.join(' ')
    end
  end
end
