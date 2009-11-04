module Effigy
  # Proxy class for performing transformations with a set selection.
  #
  # Selections are created and returned when calling {View#find} without a
  # block. Any methods called on the Selection will be forwarded to the given
  # view with the given selector inserted at the front of the argument list.
  #
  # All methods should return the Selection itself, so transformation methods
  # can be chained on a selection.
  #
  # Normally, Selections are not instantiated directly, but by calling
  # {View#find}.
  #
  # @example
  #  view = Effigy::View.new
  #  # same as calling view.remove_class('.active', 'inactive')
  #  view.find('.active').remove_class('inactive')
  class Selection

    # Creates a selection over the given view using the given selector.
    # @param view [View] the view to which transformations should be forwarded
    # @param selector [String] the selector that should be used for forwarded
    #   transformation methods
    def initialize(view, selector)
      @view     = view
      @selector = selector
    end

    # Undefined methods are forwarded to the view with the selector inserted at
    # the beginning of the argument list. The Selection is then returned for
    # chaining.
    #
    # @return [Selection] self
    def method_missing(method, *args, &block)
      @view.send(method, @selector, *args, &block)
      self
    end
  end
end
