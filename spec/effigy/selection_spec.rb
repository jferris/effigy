require 'spec_helper'
require 'effigy/selection'

module Effigy
  describe Selection do
    %w(text).each do |method|
      it "should delegate #{method} to its view" do
        view = stub('a view')
        selector = '.findme'
        arguments = [1, 2, 3]
        view.should_receive(method).with(selector, *arguments)
        selection = Selection.new(view, selector)
        selection.send(method, *arguments)
      end
    end

    it "should return itself after delegating" do
      view = stub('a view')
      view.stub!(:text)
      selection = Selection.new(view, '.findme')
      selection.text.should == selection
    end

    class BlockRecorder
      attr_reader :block
      def run(*args, &block)
        @block = block
      end
    end

    it "should pass blocks when delegating" do
      view = BlockRecorder.new
      block = lambda { 'hello' }
      selection = Selection.new(view, '.findme')
      selection.run(&block)
      view.block.should == block
    end
  end
end
