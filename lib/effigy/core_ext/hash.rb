# Internal use only.
#
# Extends Hash to easily convert a hash or key, value pair to a hash.
class Hash
  # @return [Hash] self
  # @param [Object] value ignored
  # @see Object#to_effigy_attributes
  def to_effigy_attributes(value)
    self
  end
end
