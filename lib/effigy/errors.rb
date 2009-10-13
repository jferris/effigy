module Effigy
  class ElementNotFound < StandardError
    attr_accessor :selector

    def initialize(selector)
      @selector = selector
    end

    def message
      "No element matched the given selector: #{selector.inspect}"
    end
  end
end

