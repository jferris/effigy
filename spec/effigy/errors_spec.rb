require 'spec_helper'
require 'effigy/errors'

describe Effigy::ElementNotFound do
  it "should accept a selector and use it in the message" do
    error = Effigy::ElementNotFound.new('user.selected')
    error.selector.should == 'user.selected'
    error.message.should include('user.selected')
  end
end
