module Effigy
  class Selection
    def initialize(view, selector)
      @view     = view
      @selector = selector
    end

    def method_missing(method, *args, &block)
      @view.send(method, @selector, *args, &block)
      self
    end
  end
end
