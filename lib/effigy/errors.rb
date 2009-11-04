module Effigy
  # Raised when attempting to select an element that isn't on the source
  # template.
  class ElementNotFound < StandardError
    # [String] The selector that didn't match any elements
    attr_accessor :selector

    # @param [String] the selector that didn't match any elements
    def initialize(selector)
      @selector = selector
    end

    # @return [String] a description of the failed search
    def message
      "No element matched the given selector: #{selector.inspect}"
    end
  end
end

