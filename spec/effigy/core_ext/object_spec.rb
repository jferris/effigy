require 'spec_helper'
require 'effigy/core_ext/object'

describe Object do
  it "should return itself as the key of an effigy attribute hash" do
    key = :key
    value = :value
    key.to_effigy_attributes(value).should == { key => value }
  end
end
