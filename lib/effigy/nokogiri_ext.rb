require 'nokogiri'

module Nokogiri
  module XML
    # Adds or updates the given attribute or attributes.
    # @param [Hash] attributes keys as attribute names and values as attribute
    #   values
    class Node
      def merge!(new_attributes)
        new_attributes.each do |name, value|
          self[name.to_s] = value
        end
      end

      # Parses and appends the given html fragment to the end of this node.
      # @param [String] html_to_append the html fragment that should be appended
      def append_fragment(html_to_append)
        fragment(html_to_append).children.each do |child|
          self << child
        end
      end
    end
  end
end
