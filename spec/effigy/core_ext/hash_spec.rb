require 'spec_helper'
require 'effigy/core_ext/hash'

describe Hash do
  it "should return itself as an attribute hash" do
    hash = { :key => :value }
    hash.to_effigy_attributes(nil).should == hash
  end
end

