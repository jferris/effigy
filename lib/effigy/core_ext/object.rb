# Internal use only.
#
# Extends Object to easily convert a hash or key, value pair to a hash.
class Object
  # @return [Hash] a hash composed of the object as the key and the given value
  #   as the value.
  # @param [Object] value the value to use in the generated hash
  # @see Hash#to_effigy_attributes
  def to_effigy_attributes(value)
    { self => value }
  end
end
